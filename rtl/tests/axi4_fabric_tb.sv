`timescale 1ns / 1ns
module axi4_fabric_tb;
  reg clk = 0, rst = 1;
  always #5 clk = ~clk;
  reg awid = 0;
  reg [31:0] awaddr = 0;
  reg [7:0] awlen = 0;
  reg [2:0] awsize = 0;
  reg [1:0] awburst = 0;
  reg awlock = 0;
  reg [3:0] awcache = 0;
  reg [2:0] awprot = 0;
  reg [3:0] awqos = 0;
  reg [3:0] awregion = 0;
  reg awvalid = 0;
  wire awready;
  reg arid = 0;
  reg [31:0] araddr = 0;
  reg [7:0] arlen = 0;
  reg [2:0] arsize = 0;
  reg [1:0] arburst = 0;
  reg arlock = 0;
  reg [3:0] arcache = 0;
  reg [2:0] arprot = 0;
  reg [3:0] arqos = 0;
  reg [3:0] arregion = 0;
  reg arvalid = 0;
  wire arready;
  reg [31:0] wdata = 0;
  reg [3:0] wstrb = 0;
  reg wlast = 0;
  reg wvalid = 0;
  wire wready;
  wire bid;
  wire [1:0] bresp;
  wire bvalid;
  reg bready = 0;
  wire rid;
  wire [31:0] rdata;
  wire [1:0] rresp;
  wire rlast;
  wire rvalid;
  reg rready = 0;
  wire [31:0] tohost;
  reg [31:0] model [0:16383];
  integer checks = 0, clock_count = 0, uart_reads = 0, uart_writes = 0;
  integer ar_count = 0, r_count = 0, aw_count = 0, w_count = 0, b_count = 0;
  string wave;
  axi4_subsystem #(.RAM_BANK0_HEX(""), .RAM_BANK1_HEX("")) dut (
      .clk(clk), .rst(rst), .uart_rxd(1'b1), .uart_txd(), .tohost_value(tohost),
      .s_axi_awid(awid),
      .s_axi_awaddr(awaddr),
      .s_axi_awlen(awlen),
      .s_axi_awsize(awsize),
      .s_axi_awburst(awburst),
      .s_axi_awlock(awlock),
      .s_axi_awcache(awcache),
      .s_axi_awprot(awprot),
      .s_axi_awqos(awqos),
      .s_axi_awregion(awregion),
      .s_axi_awvalid(awvalid),
      .s_axi_awready(awready),
      .s_axi_arid(arid),
      .s_axi_araddr(araddr),
      .s_axi_arlen(arlen),
      .s_axi_arsize(arsize),
      .s_axi_arburst(arburst),
      .s_axi_arlock(arlock),
      .s_axi_arcache(arcache),
      .s_axi_arprot(arprot),
      .s_axi_arqos(arqos),
      .s_axi_arregion(arregion),
      .s_axi_arvalid(arvalid),
      .s_axi_arready(arready),
      .s_axi_wdata(wdata),
      .s_axi_wstrb(wstrb),
      .s_axi_wlast(wlast),
      .s_axi_wvalid(wvalid),
      .s_axi_wready(wready),
      .s_axi_bid(bid),
      .s_axi_bresp(bresp),
      .s_axi_bvalid(bvalid),
      .s_axi_bready(bready),
      .s_axi_rid(rid),
      .s_axi_rdata(rdata),
      .s_axi_rresp(rresp),
      .s_axi_rlast(rlast),
      .s_axi_rvalid(rvalid),
      .s_axi_rready(rready)
  );
  always @(posedge clk) begin
    clock_count <= clock_count + 1;
    if (!rst) begin
      if (dut.uart.uart_r_hs && !dut.uart.read_error && dut.uart.s_axi_rlast) uart_reads <= uart_reads + 1;
      if (dut.uart.uart_tx_valid) uart_writes <= uart_writes + 1;
      if (arvalid && arready) ar_count <= ar_count + 1;
      if (rvalid && rready) r_count <= r_count + 1;
      if (awvalid && awready) aw_count <= aw_count + 1;
      if (wvalid && wready) w_count <= w_count + 1;
      if (bvalid && bready) b_count <= b_count + 1;
    end
  end
  task automatic send_aw(input [31:0] addr, input integer len, input integer delay_cycles);
    repeat (delay_cycles) @(negedge clk);
    awaddr = addr; awlen = 8'(len); awvalid = 1;
    do @(posedge clk); while (!awready);
    @(negedge clk); awvalid = 0; awaddr = 32'hdeadbeef;
  endtask
  task automatic send_w(input [31:0] value, input [3:0] mask, input integer len, input integer delay_cycles);
    repeat (delay_cycles) @(negedge clk);
    for (int k=0; k<=len; k++) begin
      wdata = value + 32'(k); wstrb = mask; wlast = k == len; wvalid = 1;
      do @(posedge clk); while (!wready);
      @(negedge clk); wvalid = 0;
    end
  endtask
  task automatic write_word(input [31:0] addr, input [31:0] value, input [3:0] mask,
                            input integer adelay=0, input integer wdelay=0,
                            input [1:0] expected_resp=0, input integer len=0);
    integer before_aw, before_w, before_b;
    reg [31:0] beat_data;
    @(negedge clk);
    before_aw = aw_count; before_w = w_count; before_b = b_count;
    fork
      send_aw(addr, len, adelay);
      send_w(value, mask, len, wdelay);
    join
    while (!bvalid) @(negedge clk);
    repeat (3) begin
      if (!bvalid || bresp !== expected_resp || bid !== awid)
        $fatal(1, "B response incorrect/unstable addr=%h", addr);
      @(negedge clk);
    end
    bready = 1;
    @(posedge clk);
    @(negedge clk); bready = 0;
    if (bvalid || aw_count != before_aw+1 || w_count != before_w+len+1 || b_count != before_b+1)
      $fatal(1, "write transaction count mismatch");
    if (expected_resp == 0 && addr[31:16] == 16'h8000)
      for (int k=0; k<=len; k++) begin
        beat_data = value + 32'(k);
        for (int b=0; b<4; b++) if (mask[b]) model[int'(addr[15:2])+k][b*8+:8] = beat_data[b*8+:8];
      end
    checks++;
  endtask
  task automatic read_words(input [31:0] addr, input integer len=0,
                            input [1:0] expected_resp=0, input bit stalled=0,
                            input [2:0] size=2, input [1:0] burst=1);
    reg [35:0] held;
    integer last_cycle, before_ar, before_r;
    @(negedge clk);
    before_ar = ar_count; before_r = r_count;
    araddr = addr; arlen = 8'(len); arsize = size; arburst = burst; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0; araddr = 32'hdeadbeef;
    rready = !stalled; last_cycle = -1;
    for (int k=0; k<=len; k++) begin
      if (stalled) begin
        while (!rvalid) @(negedge clk);
        held = {rdata, rresp, rid, rlast};
        repeat (1+k%4) begin
          @(negedge clk);
          if (!rvalid || held !== {rdata, rresp, rid, rlast})
            $fatal(1, "R changed under backpressure");
        end
        rready = 1;
      end
      do @(posedge clk); while (!rvalid);
      if (rid !== arid || rlast !== (k == len) || rresp !== expected_resp)
        $fatal(1, "read metadata addr=%h beat=%0d resp=%b last=%b", addr, k, rresp, rlast);
      if (expected_resp == 0 && addr[31:16] == 16'h8000 && rdata !== model[int'(addr[15:2])+k])
        $fatal(1, "read data addr=%h beat=%0d got=%h", addr, k, rdata);
      if (!stalled && k != 0 && clock_count != last_cycle+1)
        $fatal(1, "RAM burst did not sustain one beat per cycle");
      last_cycle = clock_count;
      @(negedge clk);
      if (stalled) rready = 0;
    end
    rready = 0;
    if (ar_count != before_ar+1 || r_count != before_r+len+1 || rvalid)
      $fatal(1, "burst request/response count mismatch");
    checks++;
  endtask
  integer before_reads, before_writes;
  initial begin
    if ($value$plusargs("wave=%s", wave)) begin $dumpfile(wave); $dumpvars(0, axi4_fabric_tb); end
    for (int k=0; k<16384; k++) model[k] = 0;
    repeat (3) @(negedge clk); rst = 0;
    awsize = 2; awburst = 1; arsize = 2; arburst = 1; awid = 1; arid = 1;
    // Distinct words in both banks and at both ends of RAM.
    for (int k=0; k<16; k++) begin
      write_word(32'h80000000 + 32'(k*4), 32'habcd0000+32'(k), 15, k%3, (15-k)%4);
      write_word(32'h8000ffc0 + 32'(k*4), 32'h12340000+32'(k), 15);
    end
    for (int mask=0; mask<16; mask++) begin
      write_word(32'h80000004, 32'h31415926 ^ 32'(mask*971), 4'(mask), mask%2, (mask+1)%3);
      read_words(32'h80000004, 0, 0, 1);
    end
    read_words(32'h80000000, 15);
    read_words(32'h80000000, 15, 0, 1);
    read_words(32'h8000ffc0, 15);
    // Native RAM bursts traverse the same fabric as CPU single writes. AW and
    // the W stream may arrive in either order, with one B for the entire line.
    write_word(32'h80000000, 32'h56780000, 15, 0, 4, 0, 15);
    read_words(32'h80000000, 15);
    write_word(32'h80000000, 32'habcdef00, 5, 5, 0, 0, 15);
    read_words(32'h80000000, 15, 0, 1);
    write_word(32'h8000ffc0, 32'hface0000, 15, 0, 0, 0, 15);
    read_words(32'h8000ffc0, 15);
    write_word(32'h80000000, 32'hffffffff, 0, 0, 0, 0, 15);
    read_words(32'h80000000, 15);
    // Replace a consumed single-beat response with another AR at the same
    // edge. This preserves the disabled-cache fetch throughput.
    @(negedge clk); araddr = 32'h80000000; arlen = 0; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0; rready = 0;
    while (!rvalid) @(negedge clk);
    araddr = 32'h80000004; arvalid = 1; rready = 1;
    @(posedge clk);
    if (!arready || !rvalid || !rlast || rdata != model[0])
      $fatal(1, "single-beat response/new AR replacement failed");
    @(negedge clk); arvalid = 0;
    @(posedge clk);
    if (!rvalid || !rlast || rdata != model[1])
      $fatal(1, "replacement read added a response bubble");
    @(negedge clk); rready = 0;
    // Boundary/type/size errors must respond completely without RAM writes.
    read_words(32'h80000ffc, 15, 2, 1);
    read_words(32'h80000002, 0, 2);
    read_words(32'h80000000, 0, 2, 1, 1);
    read_words(32'h80000000, 0, 2, 0, 2, 2);
    read_words(32'h80000000, 2, 2);
    read_words(32'h90000000, 15, 3, 1);
    write_word(32'h90000000, 32'hdeadbeef, 15, 0, 4, 3, 3);
    write_word(32'h80000000, 32'hdeadbeef, 15, 3, 0, 2, 3);
    write_word(32'h80000ffc, 32'hdeadbeef, 15, 0, 3, 2, 15);
    write_word(32'h80000002, 32'hdeadbeef, 15, 0, 2, 2);
    awsize = 1;
    write_word(32'h80000000, 32'hdeadbeef, 15, 0, 2, 2);
    awsize = 2;
    read_words(32'h80000000, 15, 0, 1);
    // UART rejects unsupported bursts without register side effects.
    before_reads = uart_reads; before_writes = uart_writes;
    read_words(32'h10000008, 15, 2, 1);
    write_word(32'h10000000, 32'h55, 1, 0, 2, 2, 3);
    if (uart_reads != before_reads || uart_writes != before_writes)
      $fatal(1, "rejected UART burst caused side effects");
    read_words(32'h10000004, 0);
    write_word(32'h10000000, 32'h41, 1, 5, 0);
    if (uart_reads != before_reads+1 || uart_writes != before_writes+1)
      $fatal(1, "UART request duplicated/lost");
    write_word(32'h80001000, 32'h01234567, 15);
    write_word(32'h80001000, 32'h89abcdef, 5);
    if (tohost !== model[1024]) $fatal(1, "tohost byte-mask mismatch");
    // Reset cancels a held B; the already committed write remains in RAM.
    @(negedge clk);
    fork
      send_aw(32'h80000008, 0, 0);
      send_w(32'hdecafbad, 15, 0, 2);
    join
    while (!bvalid) @(negedge clk);
    model[2] = 32'hdecafbad;
    rst = 1;
    @(negedge clk);
    if (bvalid) $fatal(1, "blocked B survived reset");
    rst = 0;
    read_words(32'h80000008);
    // Reset cancels blocked burst reads without clearing storage.
    @(negedge clk); araddr = 32'h80000000; arlen = 15; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0;
    while (!rvalid) @(negedge clk);
    repeat (3) @(negedge clk);
    rst = 1;
    @(negedge clk);
    if (rvalid || bvalid) $fatal(1, "response survived reset");
    rst = 0;
    read_words(32'h80000000, 15);
    if (tohost != 0) $fatal(1, "tohost did not reset");
    $display("[AXI4-FABRIC] PASS checks=%0d AR=%0d R=%0d AW=%0d W=%0d B=%0d", checks, ar_count, r_count, aw_count, w_count, b_count);
    $finish;
  end
  initial begin #200000; $fatal(1, "AXI4 fabric timeout"); end
endmodule
