`include "define.v"
`timescale 1ns/1ps
module cl(
  input [31:0]data_i,
  input start_i,
  input rst,
  input clk,
  input [7:0]cl_aluop_i,
  output reg [31:0]result_o
);
wire [31:0] out;
wire [31:0]in;
reg enable;
reg [7:0]cl_aluop_o;
assign out = data_i;
clzw clzw1(
  .rst(rst),
  .cloz_i(out),
  .start_i(enable),
  .clzw_aluop_i(cl_aluop_o),
  .result(in)
);
always@(*) begin
  if(rst == 1'b1)begin
    result_o <= 32'b00;
	enable <= 1'b0;
	cl_aluop_o <= 8'b00;
  end else begin
    if(start_i == 1'b0) begin
    result_o <= 32'b00;
	enable <= 1'b0;
	cl_aluop_o <= 8'b00;
	end else if(start_i == 1'b1)begin
    result_o <= in;
	enable <= 1'b1;
	cl_aluop_o <= cl_aluop_i;
	end 
end 
end
endmodule
