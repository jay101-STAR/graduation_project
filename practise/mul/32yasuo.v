`timescale 1ns/1ps
module full_adder(input   [67:0] a,
                  input   [67:0] b,
		  input   [67:0] ci,
		  output  [67:0] s,
		  output  [67:0] co);

  assign s  = a ^ b ^ ci;
  assign co = ((a & b) | (a & ci) | (b & ci)) << 1'b1;
endmodule
