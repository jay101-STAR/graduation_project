`timescale 1ns / 1ns

module axi_ram_unit_tb;
  reg clk = 1'b0, rst = 1'b1;
  reg direct_mode = 1'b1;
  wire uart_txd;
  wire [31:0] tohost_value, direct_tohost;
  reg [31:0] axi_awaddr = '0;
  reg [2:0] axi_awprot = '0;
  reg axi_awvalid = '0;
  wire axi_awready;
  wire bus_awready, direct_awready;
  reg [31:0] axi_wdata = '0;
  reg [3:0] axi_wstrb = '0;
  reg axi_wvalid = '0;
  wire axi_wready;
  wire bus_wready, direct_wready;
  wire [1:0] axi_bresp;
  wire [1:0] bus_bresp, direct_bresp;
  wire axi_bvalid;
  wire bus_bvalid, direct_bvalid;
  reg axi_bready = '0;
  reg [31:0] axi_araddr = '0;
  reg [2:0] axi_arprot = '0;
  reg axi_arvalid = '0;
  wire axi_arready;
  wire bus_arready, direct_arready;
  wire [31:0] axi_rdata;
  wire [31:0] bus_rdata, direct_rdata;
  wire [1:0] axi_rresp;
  wire [1:0] bus_rresp, direct_rresp;
  wire axi_rvalid;
  wire bus_rvalid, direct_rvalid;
  reg axi_rready = '0;
  always #5 clk = ~clk;

  axi_lite_subsystem #(.RAM_BANK0_HEX(""), .RAM_BANK1_HEX("")) dut (
      .clk(clk), .rst(rst), .uart_rxd(1'b1), .uart_txd(uart_txd), .tohost_value(tohost_value),
      .s_axi_awaddr(axi_awaddr),
      .s_axi_awprot(axi_awprot),
      .s_axi_awvalid((axi_awvalid && !direct_mode)),
      .s_axi_awready(bus_awready),
      .s_axi_wdata(axi_wdata),
      .s_axi_wstrb(axi_wstrb),
      .s_axi_wvalid((axi_wvalid && !direct_mode)),
      .s_axi_wready(bus_wready),
      .s_axi_bresp(bus_bresp),
      .s_axi_bvalid(bus_bvalid),
      .s_axi_bready(axi_bready),
      .s_axi_araddr(axi_araddr),
      .s_axi_arprot(axi_arprot),
      .s_axi_arvalid((axi_arvalid && !direct_mode)),
      .s_axi_arready(bus_arready),
      .s_axi_rdata(bus_rdata),
      .s_axi_rresp(bus_rresp),
      .s_axi_rvalid(bus_rvalid),
      .s_axi_rready(axi_rready)
  );

  axi_lite_ram_slave #(.BANK0_HEX(""), .BANK1_HEX("")) direct_ram (
      .clk(clk), .rst(rst), .tohost_value(direct_tohost),
      .s_axi_awaddr(axi_awaddr),
      .s_axi_awprot(axi_awprot),
      .s_axi_awvalid((axi_awvalid && direct_mode)),
      .s_axi_awready(direct_awready),
      .s_axi_wdata(axi_wdata),
      .s_axi_wstrb(axi_wstrb),
      .s_axi_wvalid((axi_wvalid && direct_mode)),
      .s_axi_wready(direct_wready),
      .s_axi_bresp(direct_bresp),
      .s_axi_bvalid(direct_bvalid),
      .s_axi_bready(axi_bready),
      .s_axi_araddr(axi_araddr),
      .s_axi_arprot(axi_arprot),
      .s_axi_arvalid((axi_arvalid && direct_mode)),
      .s_axi_arready(direct_arready),
      .s_axi_rdata(direct_rdata),
      .s_axi_rresp(direct_rresp),
      .s_axi_rvalid(direct_rvalid),
      .s_axi_rready(axi_rready)
  );
  assign axi_awready = direct_mode ? direct_awready : bus_awready;
  assign axi_wready = direct_mode ? direct_wready : bus_wready;
  assign axi_bresp = direct_mode ? direct_bresp : bus_bresp;
  assign axi_bvalid = direct_mode ? direct_bvalid : bus_bvalid;
  assign axi_arready = direct_mode ? direct_arready : bus_arready;
  assign axi_rdata = direct_mode ? direct_rdata : bus_rdata;
  assign axi_rresp = direct_mode ? direct_rresp : bus_rresp;
  assign axi_rvalid = direct_mode ? direct_rvalid : bus_rvalid;

  integer writes = 0, tx_starts = 0;
  integer n, lane, idx;
  reg [31:0] gold [0:15];
  reg [31:0] test_data;
  reg [3:0] test_mask;
  always @(posedge clk) begin
    if (!rst && !direct_mode && (|dut.ram.ram_we)) writes = writes + 1;
    if (!rst && !direct_mode && dut.uart.uart_tx_valid) tx_starts = tx_starts + 1;
  end

  task automatic send_aw(input [31:0] addr, input integer delay_cycles);
    begin
      repeat (delay_cycles) @(negedge clk);
      @(negedge clk);
      axi_awaddr = addr;
      axi_awvalid = 1'b1;
      do @(posedge clk); while (!axi_awready);
      @(negedge clk);
      axi_awvalid = 1'b0;
      axi_awaddr = 32'hdeadbeef;
    end
  endtask
  task automatic send_w(input [31:0] data, input [3:0] mask, input integer delay_cycles);
    begin
      repeat (delay_cycles) @(negedge clk);
      @(negedge clk);
      axi_wdata = data;
      axi_wstrb = mask;
      axi_wvalid = 1'b1;
      do @(posedge clk); while (!axi_wready);
      @(negedge clk);
      axi_wvalid = 1'b0;
      axi_wdata = ~data;
      axi_wstrb = ~mask;
    end
  endtask
  task automatic write_word(input [31:0] addr, input [31:0] data, input [3:0] mask,
                            input integer order, input integer hold_cycles, input [1:0] expected_resp);
    begin
      fork
        send_aw(addr, order == 1 ? 5 : 0);
        send_w(data, mask, order == 2 ? 5 : 0);
      join
      while (!axi_bvalid) @(negedge clk);
      repeat (hold_cycles + 1) begin
        if (!axi_bvalid || axi_bresp != expected_resp) $fatal(1, "Wrong/unstable B response addr=%h", addr);
        @(negedge clk);
      end
      axi_bready = 1'b1;
      @(negedge clk);
      axi_bready = 1'b0;
      if (axi_bvalid) $fatal(1, "Duplicate B response");
    end
  endtask
  task automatic read_word(input [31:0] addr, input [31:0] expected,
                           input [1:0] expected_resp, input integer hold_cycles);
    begin
      @(negedge clk);
      axi_araddr = addr;
      axi_arvalid = 1'b1;
      do @(posedge clk); while (!axi_arready);
      @(negedge clk);
      axi_arvalid = 1'b0;
      axi_araddr = 32'hdeadbeef;
      while (!axi_rvalid) @(negedge clk);
      repeat (hold_cycles + 1) begin
        if (!axi_rvalid || axi_rresp != expected_resp || axi_rdata != expected)
          $fatal(1, "Wrong/unstable R addr=%h got=%h expected=%h resp=%b", addr, axi_rdata, expected, axi_rresp);
        @(negedge clk);
      end
      axi_rready = 1'b1;
      @(negedge clk);
      axi_rready = 1'b0;
      if (axi_rvalid) $fatal(1, "Duplicate R response");
    end
  endtask

  task automatic stream_reads(input [31:0] first, input [31:0] second);
    begin
      @(negedge clk); axi_araddr = 32'h80006000; axi_arvalid = 1'b1;
      do @(posedge clk); while (!axi_arready);
      @(negedge clk); axi_araddr = 32'h80006004; axi_rready = 1'b1;
      @(posedge clk);
      if (!axi_rvalid || axi_rdata != first || axi_rresp || !axi_arready)
        $fatal(1, "Read response/new address did not overlap");
      @(negedge clk); axi_arvalid = 1'b0;
      @(posedge clk);
      if (!axi_rvalid || axi_rdata != second || axi_rresp)
        $fatal(1, "Back-to-back bank read failed");
      @(negedge clk); axi_rready = 1'b0;
      if (axi_rvalid) $fatal(1, "Duplicate streamed response");
    end
  endtask

  initial begin
    repeat (3) @(negedge clk);
    rst = 1'b0;
    // Exercise the RAM slave itself, without the interconnect combining AW/W.
    write_word(32'h80006000, 32'h12345678, 4'hf, 1, 4, 0);
    write_word(32'h80006004, 32'h89abcdef, 4'hf, 2, 5, 0);
    read_word(32'h80006000, 32'h12345678, 0, 5);
    read_word(32'h80006004, 32'h89abcdef, 0, 0);
    stream_reads(32'h12345678, 32'h89abcdef);
    // A blocked response must retain the value sampled by its AR, even if
    // the independent write channel changes that same RAM word afterwards.
    fork
      read_word(32'h80006000, 32'h12345678, 0, 30);
      begin
        repeat (5) @(negedge clk);
        write_word(32'h80006000, 32'ha5a55a5a, 4'hf, 0, 2, 0);
      end
    join
    read_word(32'h80006000, 32'ha5a55a5a, 0, 1);
    // Reset discards an incomplete address transaction, preserving RAM data.
    send_aw(32'h80006000, 0);
    @(negedge clk); rst = 1'b1;
    repeat (2) @(negedge clk);
    rst = 1'b0;
    read_word(32'h80006000, 32'ha5a55a5a, 0, 2);

    @(negedge clk); direct_mode = 1'b0;
    // Every byte strobe combination, both bank parities, and all AW/W orders.
    for (n = 0; n < 16; n = n + 1) gold[n] = 32'b0;
    for (n = 0; n < 64; n = n + 1) begin
      idx = n % 16;
      test_data = 32'h9e3779b9 * (32'(n) + 1);
      test_mask = 4'(n % 16);
      write_word(32'h80006000 + 32'(idx * 4), test_data, test_mask, n % 3, n % 5, 0);
      for (lane = 0; lane < 4; lane = lane + 1)
        if (test_mask[lane]) gold[idx][lane*8 +: 8] = test_data[lane*8 +: 8];
      read_word(32'h80006000 + 32'(idx * 4), gold[idx], 0, n % 7);
    end
    if (writes != 60) $fatal(1, "RAM writes repeated/lost: %0d", writes);
    stream_reads(gold[0], gold[1]);
    // Last word is valid; high-address aliases and out-of-range accesses fail.
    write_word(32'h8000fffc, 32'hcafebabe, 4'hf, 0, 3, 0);
    read_word(32'h8000fffc, 32'hcafebabe, 0, 3);
    write_word(32'h90006000, 32'hffffffff, 4'hf, 1, 2, 2'b11);
    read_word(32'h90006000, 0, 2'b11, 2);
    read_word(32'h80010000, 0, 2'b11, 2);
    write_word(32'h80006001, 32'hffffffff, 4'hf, 2, 2, 2'b10);
    read_word(32'h80006001, 0, 2'b10, 2);
    read_word(32'h80006000, gold[0], 0, 1);
    // Unmapped transactions never leak onto UART or modify RAM.
    read_word(32'h10000004, 32'd1, 0, 4);
    write_word(32'h10000000, 32'h41000000, 4'b1000, 1, 5, 0);
    read_word(32'h10000004, 32'd0, 0, 2);
    // RAM is usable while UART's independent serial transmitter is busy.
    write_word(32'h80006000, 32'h11223344, 4'hf, 2, 4, 0);
    fork
      read_word(32'h80006000, 32'h11223344, 0, 8);
      write_word(32'h80006004, 32'h55667788, 4'hf, 1, 4, 0);
    join
    read_word(32'h80006004, 32'h55667788, 0, 1);
    write_word(32'h80001000, 32'h12345678, 4'hf, 0, 2, 0);
    write_word(32'h80001000, 32'hab000000, 4'b1000, 2, 3, 0);
    if (tohost_value != 32'hab345678 || tx_starts != 1)
      $fatal(1, "tohost byte merge or UART exactly-once failure");
    // A pending read response is cancelled by reset; memory survives.
    @(negedge clk); axi_araddr = 32'h80006000; axi_arvalid = 1'b1;
    do @(posedge clk); while (!axi_arready);
    @(negedge clk); axi_arvalid = 1'b0;
    wait (axi_rvalid);
    @(negedge clk); rst = 1'b1;
    repeat (2) @(negedge clk);
    rst = 1'b0;
    if (axi_rvalid || axi_bvalid) $fatal(1, "Stale response survived reset");
    read_word(32'h80006000, 32'h11223344, 0, 2);
    $display("[AXI-RAM-UNIT] PASS: AW/W orders, all WSTRB masks, held B/R, routing, errors, reset, UART");
    $finish;
  end
  initial begin
    #1000000;
    $fatal(1, "TIMEOUT");
  end
endmodule

