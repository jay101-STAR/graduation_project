`timescale 1ns / 1ns

module fetch_mem_adapter_tb;
  reg clk = 0, rst = 1;
  reg req_valid = 0, rsp_ready = 0, mem_req_ready = 1, mem_rsp_valid = 0, mem_rsp_error = 0;
  reg [3:0] req_id = 0;
  reg [31:0] req_addr = 32'h80000000, mem_rsp_rdata = 0;
  wire req_ready, rsp_valid, rsp_error, mem_req_valid, mem_rsp_ready;
  wire [3:0] rsp_id;
  wire [31:0] rsp_rdata, mem_req_addr;
  integer native_requests = 0;
  always #5 clk = ~clk;
  fetch_mem_adapter dut (
      .clk(clk), .rst(rst), .req_valid(req_valid), .req_ready(req_ready), .req_id(req_id), .req_addr(req_addr),
      .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_id(rsp_id), .rsp_rdata(rsp_rdata), .rsp_error(rsp_error),
      .mem_req_valid(mem_req_valid), .mem_req_ready(mem_req_ready), .mem_req_addr(mem_req_addr),
      .mem_rsp_valid(mem_rsp_valid), .mem_rsp_ready(mem_rsp_ready),
      .mem_rsp_rdata(mem_rsp_rdata), .mem_rsp_error(mem_rsp_error)
  );
  always @(posedge clk)
    if (!rst && mem_req_valid && mem_req_ready) native_requests <= native_requests + 1;

  task automatic check_reply(input [3:0] id, input [31:0] data, input bit error_op);
    if (!rsp_valid || rsp_id != id || rsp_rdata != data || rsp_error != error_op)
      $fatal(1, "Unexpected fetch response id=%d data=%h error=%b", rsp_id, rsp_rdata, rsp_error);
  endtask

  initial begin
    repeat (3) @(negedge clk); rst = 0;
    // Both invalid range and unaligned fetch fail locally, without a bus read.
    req_valid = 1; req_addr = 32'h90000000; req_id = 4'hf;
    @(posedge clk); if (!req_ready || mem_req_valid) $fatal(1, "Invalid range reached memory");
    @(negedge clk); req_valid = 0;
    check_reply(4'hf, 0, 1);
    repeat (3) @(negedge clk);
    check_reply(4'hf, 0, 1);
    rsp_ready = 1; req_valid = 1; req_addr = 32'h80000002; req_id = 0;
    @(posedge clk); if (!req_ready || mem_req_valid) $fatal(1, "Unaligned fetch reached memory");
    @(negedge clk); req_valid = 0; rsp_ready = 0;
    check_reply(0, 0, 1);
    rsp_ready = 1;
    @(negedge clk); rsp_ready = 0;

    req_valid = 1; req_addr = 32'h80000040; req_id = 1;
    @(posedge clk);
    if (!req_ready || !mem_req_valid || mem_req_addr != 32'h80000040) $fatal(1, "Missing native fetch");
    @(negedge clk); req_valid = 0; mem_rsp_valid = 1; mem_rsp_rdata = 32'h12345678; mem_rsp_error = 1;
    @(posedge clk);
    if (!mem_rsp_ready) $fatal(1, "Core stall held the shared bus");
    check_reply(1, 32'h12345678, 1);
    @(negedge clk); mem_rsp_valid = 0; mem_rsp_rdata = 32'hdeadbeef; mem_rsp_error = 0;
    repeat (5) begin
      check_reply(1, 32'h12345678, 1);
      if (req_ready || mem_req_valid) $fatal(1, "Buffered fetch was overwritten");
      @(negedge clk);
    end
    // Consume buffered return and accept its replacement at the same edge.
    rsp_ready = 1; req_valid = 1; req_addr = 32'h80000044; req_id = 2;
    @(posedge clk);
    check_reply(1, 32'h12345678, 1);
    if (!req_ready || !mem_req_valid) $fatal(1, "Buffered replacement failed");
    @(negedge clk); req_valid = 0; mem_rsp_valid = 1; mem_rsp_rdata = 32'haabbccdd;
    #1;
    check_reply(2, 32'haabbccdd, 0);
    // A second return passes through without an added response register cycle.
    @(posedge clk); if (!mem_rsp_ready) $fatal(1, "Fall-through response stalled");
    @(negedge clk); mem_rsp_valid = 0; rsp_ready = 0;
    #1;
    if (rsp_valid || native_requests != 2) $fatal(1, "Repeated/lost fetch");
    req_valid = 1; req_addr = 32'h80000048;
    @(negedge clk); req_valid = 0; rst = 1;
    repeat (2) @(negedge clk); rst = 0;
    #1;
    if (rsp_valid) $fatal(1, "Stale fetch survived reset");
    $display("[FETCH-UNIT] PASS: local errors, ID wrap, buffered error/data, replacement, bypass, reset");
    $finish;
  end
  initial begin
    #10000; $fatal(1, "TIMEOUT");
  end
endmodule
