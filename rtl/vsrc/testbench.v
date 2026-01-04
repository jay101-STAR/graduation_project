`timescale 1ns / 1ns

module testbench ();

  reg clk;
  reg rst;

  initial begin
    clk = 1'b0;
    forever begin
      #10 clk = ~clk;
    end
  end

  initial begin
    rst = 1'b1;
    #200 rst = 1'b0;
    #2000 $finish;
  end

  top top (
      .clk(clk),
      .rst(rst)
  );

  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/rtl/testbench.fsdb");
    $fsdbDumpvars("+all");
  end


endmodule


