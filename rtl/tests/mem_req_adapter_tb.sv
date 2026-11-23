`timescale 1ns / 1ns

module mem_req_adapter_tb;
  reg clk = 1'b0, rst = 1'b1;
  reg req_valid = 1'b0, req_write = 1'b0, rsp_ready = 1'b0;
  reg [3:0] req_id = 4'b0;
  reg [31:0] req_addr = 32'b0, req_wdata = 32'b0;
  reg [7:0] req_alucex = 8'b0;
  wire req_ready, rsp_valid, rsp_error, backend_start, backend_write;
  wire [3:0] rsp_id;
  wire [31:0] rsp_rdata, backend_addr, backend_wdata;
  wire [7:0] backend_alucex;
  reg backend_busy = 1'b0, backend_error = 1'b0;
  reg [31:0] backend_rdata = 32'b0;
  reg [31:0] backend_fault_addr = 32'b0;
  wire [31:0] rsp_fault_addr;
  integer starts = 0;
  integer writes = 0;

  always #5 clk = ~clk;
  always @(posedge clk) begin
    if (!rst && backend_start) begin
      starts = starts + 1;
      if (backend_write) writes = writes + 1;
    end
  end

  mem_req_adapter dut (
      .clk(clk), .rst(rst),
      .req_valid(req_valid), .req_ready(req_ready), .req_id(req_id),
      .req_addr(req_addr), .req_write(req_write), .req_wdata(req_wdata),
      .req_alucex(req_alucex),
      .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_id(rsp_id),
      .rsp_rdata(rsp_rdata), .rsp_error(rsp_error),
      .rsp_fault_addr(rsp_fault_addr),
      .backend_start(backend_start), .backend_addr(backend_addr),
      .backend_write(backend_write), .backend_wdata(backend_wdata),
      .backend_alucex(backend_alucex), .backend_busy(backend_busy),
      .backend_rdata(backend_rdata), .backend_error(backend_error),
      .backend_fault_addr(backend_fault_addr)
  );

  task automatic transact(input [3:0] id, input bit write_access,
                          input integer wait_cycles, input integer hold_cycles,
                          input bit error_response);
    reg [31:0] addr, data, expected;
    integer before_starts;
    begin
      addr = 32'h80002000 + {26'b0, id, 2'b0};
      data = 32'h12340000 + {28'b0, id};
      expected = 32'hcafe0000 + {28'b0, id};
      before_starts = starts;
      @(negedge clk);
      req_valid = 1'b1;
      req_id = id;
      req_addr = addr;
      req_write = write_access;
      req_wdata = data;
      req_alucex = 8'h5a;
      backend_busy = (wait_cycles != 0);
      backend_rdata = expected;
      backend_error = error_response;
      backend_fault_addr = addr + 32'd4;
      if (!req_ready) $fatal(1, "Empty adapter rejected request");
      @(posedge clk);
      @(negedge clk);
      // A request held high after acceptance must not restart the backend.
      repeat (2) begin
        if (req_ready || backend_start) $fatal(1, "Accepted request repeated");
        @(negedge clk);
      end
      req_valid = 1'b0;
      req_addr = 32'hffffffff;
      req_wdata = 32'hffffffff;
      req_write = !write_access;
      req_alucex = 8'hff;
      repeat (wait_cycles) begin
        if (rsp_valid) $fatal(1, "Busy backend completed early");
        @(negedge clk);
      end
      backend_busy = 1'b0;
      while (!rsp_valid) @(negedge clk);
      // Ensure the first available response has been sampled into the hold
      // register before deliberately destroying the legacy backend outputs.
      @(negedge clk);
      repeat (hold_cycles) begin
        backend_rdata = ~expected;
        backend_error = !error_response;
        backend_fault_addr = 32'hdeadbeef;
        if (!rsp_valid || rsp_id != id || rsp_rdata != expected || rsp_error != error_response ||
            rsp_fault_addr != addr + 32'd4)
          $fatal(1, "Blocked response payload/error was not retained");
        if (backend_addr != addr || backend_wdata != data || backend_write != write_access ||
            backend_alucex != 8'h5a)
          $fatal(1, "Pending backend payload followed requester changes");
        @(negedge clk);
      end
      if (rsp_id != id || rsp_rdata != expected || rsp_error != error_response)
        $fatal(1, "Wrong response");
      rsp_ready = 1'b1;
      @(negedge clk);
      rsp_ready = 1'b0;
      if (rsp_valid || !req_ready || starts != before_starts + 1)
        $fatal(1, "Completion was lost or duplicated");
    end
  endtask

  initial begin
    repeat (2) @(negedge clk);
    rst = 1'b0;
    transact(4'd1, 1'b0, 0, 0, 1'b0);
    transact(4'd2, 1'b1, 7, 5, 1'b0);
    transact(4'd3, 1'b0, 3, 4, 1'b1);
    transact(4'd4, 1'b1, 0, 6, 1'b1);
    if (starts != 4 || writes != 2) $fatal(1, "Repeated side effects");
    $display("[MEM-ADAPTER-UNIT] PASS: reads/writes, backend waits, held data/error, exactly-once start");
    $finish;
  end

  initial begin
    #10000;
    $fatal(1, "TIMEOUT");
  end
endmodule
