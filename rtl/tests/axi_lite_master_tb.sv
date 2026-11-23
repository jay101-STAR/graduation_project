`timescale 1ns / 1ns

module axi_lite_master_tb;
  reg clk = 0, rst = 1;
  reg req_valid = 0, req_write = 0, rsp_ready = 0;
  reg [31:0] req_addr = 0, req_wdata = 0;
  reg [3:0] req_wstrb = 0;
  wire req_ready, rsp_valid, rsp_error;
  wire [31:0] rsp_rdata, awaddr, wdata, araddr;
  wire [2:0] awprot, arprot;
  wire [3:0] wstrb;
  wire awvalid, wvalid, arvalid, bready, rready;
  reg awready = 0, wready = 0, arready = 0;
  reg bvalid = 0, rvalid = 0;
  reg [1:0] bresp = 0, rresp = 0;
  reg [31:0] rdata = 0;
  integer requests = 0, responses = 0, reads = 0, addresses = 0, data_beats = 0;
  reg aw_blocked = 0, w_blocked = 0, ar_blocked = 0;
  reg [31:0] held_aw, held_ar;
  reg [35:0] held_w;
  always #5 clk = ~clk;

  axi_lite_master dut (
      .clk(clk), .rst(rst), .req_valid(req_valid), .req_ready(req_ready),
      .req_addr(req_addr), .req_write(req_write), .req_wdata(req_wdata), .req_wstrb(req_wstrb),
      .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_rdata(rsp_rdata), .rsp_error(rsp_error),
      .m_axi_awaddr(awaddr), .m_axi_awprot(awprot), .m_axi_awvalid(awvalid), .m_axi_awready(awready),
      .m_axi_wdata(wdata), .m_axi_wstrb(wstrb), .m_axi_wvalid(wvalid), .m_axi_wready(wready),
      .m_axi_bresp(bresp), .m_axi_bvalid(bvalid), .m_axi_bready(bready),
      .m_axi_araddr(araddr), .m_axi_arprot(arprot), .m_axi_arvalid(arvalid), .m_axi_arready(arready),
      .m_axi_rdata(rdata), .m_axi_rresp(rresp), .m_axi_rvalid(rvalid), .m_axi_rready(rready)
  );

  always @(posedge clk) begin
    if (rst) begin
      aw_blocked <= 0; w_blocked <= 0; ar_blocked <= 0;
    end else begin
      if (aw_blocked && (!awvalid || awaddr != held_aw)) $fatal(1, "AW changed while blocked");
      if (w_blocked && (!wvalid || {wstrb, wdata} != held_w)) $fatal(1, "W changed while blocked");
      if (ar_blocked && (!arvalid || araddr != held_ar)) $fatal(1, "AR changed while blocked");
      aw_blocked <= awvalid && !awready; held_aw <= awaddr;
      w_blocked <= wvalid && !wready; held_w <= {wstrb, wdata};
      ar_blocked <= arvalid && !arready; held_ar <= araddr;
      if (req_valid && req_ready) requests <= requests + 1;
      if (rsp_valid && rsp_ready) responses <= responses + 1;
      if (arvalid && arready) reads <= reads + 1;
      if (awvalid && awready) addresses <= addresses + 1;
      if (wvalid && wready) data_beats <= data_beats + 1;
    end
  end

  task automatic offer(input bit write_op, input [31:0] address);
    begin
      @(negedge clk);
      req_valid = 1; req_write = write_op; req_addr = address;
      req_wdata = 32'h12345678; req_wstrb = 4'b1010;
      do @(posedge clk); while (!req_ready);
      @(negedge clk);
      req_valid = 0; req_addr = 32'hdeadbeef; req_wdata = 0; req_wstrb = 0;
    end
  endtask

  task automatic complete(input bit write_op, input bit error_op);
    begin
      @(negedge clk);
      rdata = 32'hcafebabe; rresp = error_op ? 2'b10 : 0; rvalid = !write_op;
      bresp = error_op ? 2'b11 : 0; bvalid = write_op;
      repeat (4) begin
        @(posedge clk);
        if (!rsp_valid || rsp_error != error_op || rsp_rdata != (write_op ? 0 : 32'hcafebabe) ||
            rready || bready || req_ready)
          $fatal(1, "Response lost/changed under backpressure");
      end
      @(negedge clk); rsp_ready = 1;
      @(posedge clk);
      if (!(write_op ? bready : rready)) $fatal(1, "Response not consumed");
      @(negedge clk); rsp_ready = 0; rvalid = 0; bvalid = 0;
      if (rsp_valid) $fatal(1, "Duplicate native response");
    end
  endtask

  task automatic read_case(input bit error_op);
    begin
      offer(0, 32'h80000100);
      repeat (3) @(negedge clk);
      if (!arvalid || araddr != 32'h80000100 || arprot != 0)
        $fatal(1, "Read payload not saved");
      arready = 1;
      @(negedge clk); arready = 0;
      if (arvalid) $fatal(1, "Duplicate AR");
      complete(0, error_op);
    end
  endtask

  task automatic write_case(input integer aw_delay, input integer w_delay, input bit error_op);
    begin
      offer(1, 32'h10000000);
      fork
        begin
          repeat (aw_delay) @(negedge clk);
          if (!awvalid || awaddr != 32'h10000000 || awprot != 0) $fatal(1, "Bad AW payload");
          awready = 1;
          @(negedge clk); awready = 0;
          if (awvalid) $fatal(1, "Duplicate AW");
        end
        begin
          repeat (w_delay) @(negedge clk);
          if (!wvalid || wdata != 32'h12345678 || wstrb != 4'b1010) $fatal(1, "Bad W payload");
          wready = 1;
          @(negedge clk); wready = 0;
          if (wvalid) $fatal(1, "Duplicate W");
        end
      join
      complete(1, error_op);
    end
  endtask

  initial begin
    repeat (3) @(negedge clk); rst = 0;
    read_case(0); read_case(1);
    write_case(0, 4, 0); write_case(5, 0, 1); write_case(0, 0, 0);
    // Stream R -> R -> write -> R, accepting a replacement on each response.
    arready = 1; awready = 1; wready = 1;
    offer(0, 32'h80000200);
    @(negedge clk);
    req_valid = 1; req_addr = 32'h80000204; rvalid = 1; rresp = 0; rdata = 32'h11111111; rsp_ready = 1;
    @(posedge clk);
    if (!req_ready || !arvalid || !rready || rsp_rdata != 32'h11111111)
      $fatal(1, "R/new AR overlap failed");
    @(negedge clk);
    req_write = 1; req_addr = 32'h10000000; req_wdata = 32'h41000000; req_wstrb = 4'h8;
    rdata = 32'h22222222;
    @(posedge clk);
    if (!req_ready || !awvalid || !wvalid || !rready || rsp_rdata != 32'h22222222)
      $fatal(1, "R/new write overlap failed");
    @(negedge clk);
    req_write = 0; req_addr = 32'h80000208; rvalid = 0; bvalid = 1; bresp = 0;
    @(posedge clk);
    if (!req_ready || !arvalid || !bready || !rsp_valid) $fatal(1, "B/new AR overlap failed");
    @(negedge clk);
    req_valid = 0; bvalid = 0; rvalid = 1; rdata = 32'h33333333;
    @(posedge clk);
    if (!rready || !rsp_valid || rsp_rdata != 32'h33333333) $fatal(1, "Last streamed response failed");
    @(negedge clk); rvalid = 0; rsp_ready = 0;
    if (requests != 9 || responses != 9 || reads != 5 || addresses != 4 || data_beats != 4)
      $fatal(1, "Repeated/lost transactions: req=%0d rsp=%0d AR=%0d AW=%0d W=%0d",
             requests, responses, reads, addresses, data_beats);
    // Reset cancels a request whose channels have not yet been accepted.
    arready = 0; offer(0, 32'h80000300);
    rst = 1;
    repeat (2) @(negedge clk); rst = 0;
    if (arvalid || awvalid || wvalid || rsp_valid) $fatal(1, "Stale work survived reset");
    $display("[AXI-MASTER-UNIT] PASS: saved payload, AW/W orders, R/B stalls/errors, replacement, reset");
    $finish;
  end
  initial begin
    #10000; $fatal(1, "TIMEOUT");
  end
endmodule
