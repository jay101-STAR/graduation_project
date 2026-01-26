`timescale 1ns / 1ns

module testbench ();

  reg clk;
  reg rst;
  reg [31:0] tohost_value;
  reg test_complete;


  initial begin
    clk = 1'b0;
    forever begin
      #10 clk = ~clk;
    end
  end

  initial begin
    rst           = 1'b1;
    test_complete = 1'b0;
    #200 rst = 1'b0;
    #40000;
    test_complete = 1'b1;
    #200;
  end

  top top (
      .clk         (clk),
      .rst         (rst),
      .tohost_value(tohost_value)
  );

  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/rtl/testbench.fsdb");
    $fsdbDumpvars("+all");
  end

  // Monitor tohost for test results (RISC-V test convention)
  // tohost is at address 0x80001000

  // always @(posedge clk) begin
  //   if (!rst && tohost_value != 0) begin
  //     if (tohost_value == 1) begin
  //       $display("\033[1;32m*** TEST PASSED ***\033[0m");
  //     end else begin
  //       $display("\033[1;31m*** TEST FAILED *** (tohost = %d)\033[0m", tohost_value >> 1);
  //     end
  //     #100 $finish;
  //   end
  // end
  always @(posedge clk) begin
    if (!rst && test_complete) begin
      if (tohost_value === 32'd1) begin
        $display("\033[1;32m*** TEST PASSED ***\033[0m");
      end else if (^tohost_value !== 1'bx) begin
        $display("\033[1;31m*** TEST FAILED *** (tohost = %d)\033[0m", tohost_value >> 1);
      end else begin
        $display("\033[1;33m*** TOHOST UNKNOWN (X) ***\033[0m");
      end
      #100 $finish;
    end
  end


endmodule


