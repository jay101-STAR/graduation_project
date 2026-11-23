`timescale 1ns / 1ns
module axi4_uart_tb;
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
  reg uart_rxd = 1;
  wire uart_txd;
  localparam integer CPB = 8;
  integer tx_count = 0, pop_count = 0, checks = 0;
  reg [7:0] emitted [0:127];
  string wave;
  axi4_uart_slave #(.UART_CLK_HZ(80), .UART_BAUD(10), .RX_FIFO_DEPTH(2)) dut (
      .clk(clk), .rst(rst), .uart_rxd(uart_rxd), .uart_txd(uart_txd),
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
  always @(posedge clk) if (!rst) begin
    if (dut.uart_tx_valid) begin
      emitted[tx_count] = dut.uart_tx_data;
      tx_count = tx_count + 1;
    end
    if (dut.uart_rx_pop) pop_count = pop_count + 1;
  end
  task automatic inject(input [7:0] byte_value);
    @(negedge clk); uart_rxd = 0;
    repeat (CPB) @(negedge clk);
    for (int b=0; b<8; b++) begin
      uart_rxd = byte_value[b];
      repeat (CPB) @(negedge clk);
    end
    uart_rxd = 1;
    repeat (CPB+4) @(negedge clk);
  endtask
  task automatic send_aw(input [31:0] addr, input integer len, input integer delay_cycles, input bit id);
    repeat (delay_cycles) @(negedge clk);
    awaddr = addr; awlen = 8'(len); awid = id; awvalid = 1;
    do @(posedge clk); while (!awready);
    @(negedge clk); awvalid = 0; awaddr = 32'hdeadbeef; awid = !id;
  endtask
  task automatic send_w(input [31:0] data, input [3:0] mask, input integer len,
                        input integer delay_cycles, input bit bad_last=0);
    repeat (delay_cycles) @(negedge clk);
    for (int k=0; k<=len; k++) begin
      wdata = data; wstrb = mask; wlast = (k == len) ^ bad_last; wvalid = 1;
      do @(posedge clk); while (!wready);
      @(negedge clk); wvalid = 0; wdata = ~data;
    end
  endtask
  task automatic write_reg(input [31:0] addr, input [31:0] data, input [3:0] mask,
                           input integer adelay=0, input integer wdelay=0,
                           input [1:0] resp=0, input integer len=0, input bit id=0,
                           input bit bad_last=0);
    @(negedge clk);
    fork
      send_aw(addr, len, adelay, id);
      send_w(data, mask, len, wdelay, bad_last);
    join
    while (!bvalid) @(negedge clk);
    repeat (4) begin
      if (!bvalid || bresp !== resp || bid !== id || awready || wready)
        $fatal(1, "UART B response/ID/stability addr=%h resp=%b expected=%b", addr, bresp, resp);
      @(negedge clk);
    end
    bready = 1;
    @(posedge clk);
    @(negedge clk); bready = 0;
    if (bvalid) $fatal(1, "duplicate UART B");
    checks++;
  endtask
  task automatic send_ar(input [31:0] addr, input integer len, input bit id);
    @(negedge clk);
    araddr = addr; arlen = 8'(len); arid = id; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0; araddr = 32'hdeadbeef; arid = !id;
  endtask
  task automatic finish_read(input [31:0] data, input [1:0] resp, input integer len,
                             input bit id, input integer stalls=3);
    for (int k=0; k<=len; k++) begin
      while (!rvalid) @(negedge clk);
      repeat (stalls) begin
        if (!rvalid || rdata !== data || rresp !== resp || rid !== id || rlast !== (k==len) || arready)
          $fatal(1, "UART R data/ID/LAST/stability k=%0d data=%h", k, rdata);
        @(negedge clk);
      end
      rready = 1;
      @(posedge clk);
      if (!rvalid || rdata !== data || rresp !== resp || rid !== id || rlast !== (k==len))
        $fatal(1, "UART R handshake mismatch");
      @(negedge clk); rready = 0;
    end
    if (rvalid) $fatal(1, "duplicate UART R");
    checks++;
  endtask
  task automatic read_reg(input [31:0] addr, input [31:0] data,
                          input [1:0] resp=0, input integer len=0, input bit id=0);
    send_ar(addr, len, id);
    finish_read(data, resp, len, id);
  endtask
  task automatic reset_uart;
    @(negedge clk); rst = 1; arvalid = 0; awvalid = 0; wvalid = 0;
    rready = 0; bready = 0; uart_rxd = 1;
    repeat (3) @(negedge clk);
    if (rvalid || bvalid || arready || awready || wready) $fatal(1, "UART active during reset");
    rst = 0;
    @(negedge clk);
    if (rvalid || bvalid) $fatal(1, "UART stale response after reset");
  endtask
  integer before_tx, before_pop;
  reg [7:0] expected_byte;
  initial begin
    if ($value$plusargs("wave=%s", wave)) begin $dumpfile(wave); $dumpvars(0, axi4_uart_tb); end
    awsize = 2; awburst = 1; arsize = 2; arburst = 1;
    reset_uart();
    read_reg(32'h10000004, 1, 0, 0, 1);
    // Each nonzero WSTRB chooses the lowest asserted byte lane. Zero is a no-op.
    for (int mask=0; mask<16; mask++) begin
      before_tx = tx_count;
      write_reg(32'h10000000, 32'h44332211, 4'(mask), mask%5, (mask+2)%5, 0, 0, 1'(mask));
      if (tx_count != before_tx + int'(mask != 0)) $fatal(1, "TX enqueue count mask=%h", mask);
      if (mask != 0) begin
        expected_byte = mask[0] ? 8'h11 : mask[1] ? 8'h22 : mask[2] ? 8'h33 : 8'h44;
        if (emitted[before_tx] != expected_byte) $fatal(1, "TX byte lane");
      end
    end
    before_tx = tx_count;
    write_reg(32'h10000000, 32'h55, 1, 4, 0, 2, 15, 1);
    write_reg(32'h10000000, 32'h55, 1, 0, 3, 2, 3, 0);
    write_reg(32'h10000000, 32'h55, 1, 0, 3, 2, 255, 1);
    write_reg(32'h10000000, 32'h55, 1, 4, 0, 2, 0, 1, 1);
    write_reg(32'h10000002, 32'h55, 1, 0, 2, 2);
    write_reg(32'h10000010, 32'h55, 1, 3, 0, 2);
    awsize = 1; write_reg(32'h10000000, 32'h55, 1, 1, 4, 2); awsize = 2;
    awburst = 2; write_reg(32'h10000000, 32'h55, 1, 4, 1, 2); awburst = 1;
    awlock = 1; write_reg(32'h10000000, 32'h55, 1, 4, 1, 2); awlock = 0;
    write_reg(32'h1000000c, 32'h55, 15);
    if (tx_count != before_tx) $fatal(1, "rejected/no-op write triggered TX");
    // The two-entry RX FIFO overflows on a third frame.
    inject(8'h41); inject(8'h42); inject(8'h43);
    read_reg(32'h10000004, 7, 0, 0, 1);
    before_pop = pop_count;
    read_reg(32'h10000008, 0, 2, 15, 1);
    read_reg(32'h10000008, 0, 2, 255, 0);
    read_reg(32'h1000000a, 0, 2);
    arsize = 1; read_reg(32'h10000008, 0, 2); arsize = 2;
    arburst = 0; read_reg(32'h10000008, 0, 2); arburst = 1;
    arlock = 1; read_reg(32'h10000008, 0, 2); arlock = 0;
    read_reg(32'h10000010, 0, 2);
    if (pop_count != before_pop) $fatal(1, "rejected read popped RX FIFO");
    read_reg(32'h10000008, 32'h41, 0, 0, 1);
    read_reg(32'h10000004, 3); // pop clears sticky overrun, B remains in FIFO
    read_reg(32'h10000008, 32'h42);
    read_reg(32'h10000008, 0);
    if (pop_count != before_pop+2) $fatal(1, "RX pops duplicated/lost");
    // A held response snapshots A even when B arrives before RREADY.
    inject(8'h61);
    before_pop = pop_count;
    send_ar(32'h10000008, 0, 1);
    inject(8'h62);
    if (pop_count != before_pop || rdata != 32'h61) $fatal(1, "RX pop before R handshake");
    finish_read(32'h61, 0, 0, 1, 5);
    read_reg(32'h10000008, 32'h62);
    if (pop_count != before_pop+2) $fatal(1, "held RX response lost FIFO ownership");
    // Reset cancels pending R/B, an early W, and an AW with no data.
    inject(8'h71); send_ar(32'h10000008, 0, 0); reset_uart();
    read_reg(32'h10000008, 0);
    @(negedge clk);
    fork send_aw(32'h10000000, 0, 0, 1); send_w(32'h77, 1, 0, 0); join
    while (!bvalid) @(negedge clk);
    reset_uart();
    @(negedge clk); send_w(32'h88, 1, 0, 0); reset_uart();
    @(negedge clk); send_aw(32'h10000000, 0, 0, 0); reset_uart();
    before_tx = tx_count;
    write_reg(32'h10000000, 32'h99, 1, 4, 0, 0, 0, 1);
    if (tx_count != before_tx+1 || emitted[before_tx] != 8'h99) $fatal(1, "reset retained partial write");
    $display("[AXI4-UART] PASS checks=%0d TX=%0d RX-pop=%0d", checks, tx_count, pop_count);
    $finish;
  end
  initial begin #2000000; $fatal(1, "AXI4 UART timeout"); end
endmodule
