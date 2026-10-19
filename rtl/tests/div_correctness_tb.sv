`timescale 1ns / 1ns
module div_correctness_tb;
  reg clk = 0;
  reg rst = 1;
  reg div_sign = 0;
  reg div_start = 0;
  reg [31:0] dividend = 0, divisor = 0;
  wire [31:0] quotient, remainder;
  wire done, busy;
  integer checked = 0;
  integer seed = 32'h13579abc;
  reg [31:0] edges [0:12];
  reg [31:0] random_a, random_b;

  div dut (.clk(clk), .rst(rst), .div_sign(div_sign), .div_start(div_start),
      .dividend(dividend), .divisor(divisor), .div_result_q(quotient),
      .div_result_r(remainder), .div_done(done), .div_busy(busy));
  always #5 clk = ~clk;

  task automatic check_case(input bit signed_mode, input reg [31:0] a, b);
    reg [31:0] expected_q, expected_r;
    longint signed signed_a, signed_b;
    integer cycles;
    begin
      if (b == 0) begin
        expected_q = 32'hffffffff;
        expected_r = a;
      end else if (signed_mode) begin
        signed_a = $signed(a);
        signed_b = $signed(b);
        expected_q = 32'(signed_a / signed_b);
        expected_r = 32'(signed_a % signed_b);
      end else begin
        expected_q = a / b;
        expected_r = a % b;
      end
      @(negedge clk);
      dividend = a;
      divisor = b;
      div_sign = signed_mode;
      div_start = 1;
      @(posedge clk); #1;
      @(negedge clk); div_start = 0;
      cycles = 0;
      while (!done && cycles < 40) begin
        @(posedge clk); #1;
        cycles = cycles + 1;
      end
      if (!done || quotient !== expected_q || remainder !== expected_r)
        $fatal(1, "a=%08x b=%08x signed=%0b got q=%08x r=%08x expected q=%08x r=%08x cycles=%0d",
               a, b, signed_mode, quotient, remainder, expected_q, expected_r, cycles);
      // The very next edge must return to idle, ready for the next request.
      repeat (1) begin
        @(posedge clk); #1;
        if (quotient !== expected_q || remainder !== expected_r)
          $fatal(1, "Result changed after completion");
      end
      if (busy || done) $fatal(1, "Divider did not return to idle");
      checked = checked + 1;
    end
  endtask

  initial begin
    edges[0]=0; edges[1]=1; edges[2]=2; edges[3]=3; edges[4]=7;
    edges[5]=32'h7fffffff; edges[6]=32'h80000000; edges[7]=32'hffffffff;
    edges[8]=32'hfffffffd; edges[9]=32'h40000000; edges[10]=32'h80000001;
    edges[11]=32'h00010000; edges[12]=32'h12345678;
    repeat (2) @(negedge clk);
    rst = 0;
    for (integer s=0; s<2; s=s+1)
      for (integer a=0; a<13; a=a+1)
        for (integer b=0; b<13; b=b+1)
          check_case(1'(s), edges[a], edges[b]);
    for (integer i=0; i<2000; i=i+1) begin
      random_a = $random(seed);
      random_b = $random(seed);
      // Exercise long iterative paths frequently, rather than mostly a<b.
      if (i % 3 == 0) random_b = 3;
      if (i % 3 == 1) random_b = 32'hfffffffd;
      check_case(1'(i), random_a, random_b);
    end
    // Reset during a long operation, then verify recovery on another request.
    @(negedge clk);
    dividend = 32'hffffffff; divisor = 3; div_sign = 0; div_start = 1;
    @(negedge clk); div_start = 0;
    repeat (3) @(negedge clk);
    rst = 1;
    @(posedge clk); #1;
    if (done || busy) $fatal(1, "Reset did not clear handshake");
    @(negedge clk); rst = 0;
    check_case(1, 32'hffffff9c, 3);
    $display("TEST PASSED: %0d quotient/remainder cases, output stability, reset recovery", checked);
    $finish;
  end
endmodule
