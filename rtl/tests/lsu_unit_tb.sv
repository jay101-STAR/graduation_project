`timescale 1ns / 1ns
`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module lsu_unit_tb;
  reg clk = 1'b0, rst = 1'b1, start = 1'b0, write_access = 1'b0;
  reg [31:0] addr = 32'b0, wdata = 32'b0;
  reg [7:0] op = 8'b0;
  wire busy, error, req_valid, req_ready, req_write, rsp_ready;
  wire [31:0] rdata, req_addr, req_wdata;
  wire [31:0] error_addr;
  wire [3:0] req_wstrb;
  reg rsp_valid = 1'b0, rsp_error = 1'b0;
  reg [31:0] rsp_rdata = 32'b0;
  reg pending = 1'b0;
  reg [2:0] delay_count;
  reg [31:0] saved_addr, saved_data;
  reg [3:0] saved_strb;
  reg saved_write;
  reg [31:0] fault_addr = 32'hffffffff;
  reg [31:0] memory [0:63];
  reg [15:0] random_bits = 16'hace1;
  integer transactions = 0;
  integer lane, index;
  always #5 clk = ~clk;
  assign req_ready = !rst && !pending && (random_bits[1:0] != 0);
  lsu dut (
      .clk(clk), .rst(rst), .start(start), .addr(addr), .write_access(write_access),
      .wdata(wdata), .alucex(op), .busy(busy), .rdata(rdata), .error(error),
      .fault_addr(error_addr),
      .req_valid(req_valid), .req_ready(req_ready), .req_addr(req_addr),
      .req_write(req_write), .req_wdata(req_wdata), .req_wstrb(req_wstrb),
      .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_rdata(rsp_rdata), .rsp_error(rsp_error)
  );
  always @(posedge clk) begin
    if (rst) begin
      pending <= 1'b0;
      rsp_valid <= 1'b0;
    end else begin
      random_bits <= {random_bits[14:0], random_bits[15] ^ random_bits[13] ^ random_bits[12] ^ random_bits[10]};
      if (req_valid && req_ready) begin
        if (req_addr[1:0] != 0) $fatal(1, "LSU emitted unaligned word");
        transactions = transactions + 1;
        pending <= 1'b1;
        saved_addr <= req_addr;
        saved_data <= req_wdata;
        saved_strb <= req_wstrb;
        saved_write <= req_write;
        delay_count <= {1'b0, random_bits[3:2]} + 3'd2;
      end
      if (pending && !rsp_valid) begin
        if (delay_count != 0) delay_count <= delay_count - 1'b1;
        else begin
          rsp_valid <= 1'b1;
          rsp_error <= (saved_addr == fault_addr);
          rsp_rdata <= memory[saved_addr[7:2]];
          if (saved_write && saved_addr != fault_addr)
            for (lane = 0; lane < 4; lane = lane + 1)
              if (saved_strb[lane]) memory[saved_addr[7:2]][lane*8 +: 8] <= saved_data[lane*8 +: 8];
        end
      end
      if (rsp_valid && rsp_ready) begin
        rsp_valid <= 1'b0;
        pending <= 1'b0;
      end
    end
  end
  task automatic access(input [31:0] address, input [7:0] operation, input bit wr,
                         input [31:0] data, input [31:0] expected, input bit expected_error,
                         input integer beats);
    integer before_count;
    begin
      before_count = transactions;
      @(negedge clk);
      addr = address; op = operation; write_access = wr; wdata = data; start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      while (busy) @(negedge clk);
      repeat (3) begin
        if (error != expected_error || rdata != expected || transactions != before_count + beats || req_valid)
          $fatal(1, "LSU addr=%h result=%h error=%b beats=%0d", address, rdata, error, transactions-before_count);
        @(negedge clk);
      end
    end
  endtask
  initial begin
    for (index = 0; index < 64; index = index + 1) memory[index] = 0;
    repeat (3) @(negedge clk);
    rst = 1'b0;
    access(32'h8000ff00, `SW_TYPE, 1, 32'h80ff7f01, 0, 0, 1);
    access(32'h8000ff04, `SW_TYPE, 1, 32'h11223344, 0, 0, 1);
    access(32'h8000ff03, `LB_TYPE, 0, 0, 32'hffffff80, 0, 1);
    access(32'h8000ff02, `LBU_TYPE, 0, 0, 32'h000000ff, 0, 1);
    access(32'h8000ff01, `LH_TYPE, 0, 0, 32'hffffff7f, 0, 1);
    access(32'h8000ff03, `LHU_TYPE, 0, 0, 32'h00004480, 0, 2);
    access(32'h8000ff01, `SW_TYPE, 1, 32'hdeadbeef, 0, 0, 2);
    access(32'h8000ff01, `LW_TYPE, 0, 0, 32'hdeadbeef, 0, 2);
    access(32'h8000ff04, `LW_TYPE, 0, 0, 32'h112233de, 0, 1);
    access(32'h8000ff03, `SH_TYPE, 1, 32'ha1b2, 0, 0, 2);
    access(32'h8000ff03, `LHU_TYPE, 0, 0, 32'h0000a1b2, 0, 2);
    access(32'h8000fffc, `SW_TYPE, 1, 32'h12345678, 0, 0, 1);
    access(32'h8000ffff, `SW_TYPE, 1, 32'hffffffff, 0, 1, 0);
    if (error_addr != 32'h80010000) $fatal(1, "RAM boundary fault address");
    access(32'h8000ffff, `SH_TYPE, 1, 32'hffffffff, 0, 1, 0);
    access(32'h8000fffc, `LW_TYPE, 0, 0, 32'h12345678, 0, 1);
    access(32'h9000ff00, `LW_TYPE, 0, 0, 0, 1, 0);
    if (error_addr != 32'h9000ff00) $fatal(1, "Local rejection fault address");
    access(32'h10000003, `LW_TYPE, 0, 0, 0, 1, 0);
    access(32'h8000ff00, 8'hff, 0, 0, 0, 1, 0);
    fault_addr = 32'h8000ff04;
    access(32'h8000ff01, `LW_TYPE, 0, 0, 0, 1, 2);
    if (error_addr != 32'h8000ff04) $fatal(1, "Second word fault address");
    $display("[LSU-UNIT] PASS: byte lanes, sign extension, split accesses, bounds, delayed/error responses");
    $finish;
  end
  initial begin
    #100000;
    $fatal(1, "TIMEOUT");
  end
endmodule
