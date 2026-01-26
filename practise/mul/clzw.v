`include "define.v"
`timescale 1ns/1ps
module clzw(
  input [31:0]cloz_i,
  input rst,
  input start_i,
  input [7:0]clzw_aluop_i,
  output reg [31:0]result
);

reg [15:0] data_15;
reg [7:0]  data_8;
reg [3:0]  data_4;
reg [1:0]  data_2;
always@(*)begin
if(start_i == 1'b0)begin
  result <= 32'b00;
  data_15 <= 16'b00;
  data_8 <= 8'b00;
  data_4 <= 4'b00;
  data_2 <= 2'b00;
end else begin
 case(clzw_aluop_i)
 `EXE_CLZ_OP:begin
 result[31:5] = 27'b0;
 result[4] = ~| cloz_i[31:16];
 data_15 = (~result[4])? cloz_i[31:16] : cloz_i[15:0];
 result[3] = ~| data_15[15:8];
 data_8 = (~result[3])? data_15[15:8] : data_15[7:0];
 result[2] = ~| data_8[7:4];
 data_4 = (~result[2])? data_8[7:4] : data_8[3:0];
 result[1] = ~| data_4[3:2];
 data_2 = (~result[1])? data_4[3:2] : data_4[1:0];
 result[0] =~data_2[1];
 end 
 `EXE_CLO_OP:begin
 result[31:5] = 27'b0;
 result[4] = & cloz_i[31:16];
 data_15 = (~result[4])? cloz_i[31:16] : cloz_i[15:0];
 result[3] = & data_15[15:8];
 data_8 = (~result[3])? data_15[15:8] : data_15[7:0];
 result[2] = & data_8[7:4];
 data_4 = (~result[2])? data_8[7:4] : data_8[3:0];
 result[1] = & data_4[3:2];
 data_2 = (~result[1])? data_4[3:2] : data_4[1:0];
 result[0] =data_2[1];
 end 
 `EXE_CTZ_OP:begin
 result[31:5] = 27'b0;
 result[4] = ~| cloz_i[15:0];
 data_15 = (result[4])? cloz_i[31:16] : cloz_i[15:0];
 result[3] = ~| data_15[7:0];
 data_8 = (result[3])? data_15[15:8] : data_15[7:0];
 result[2] = ~| data_8[3:0];
 data_4 = (result[2])? data_8[7:4] : data_8[3:0];
 result[1] = ~| data_4[1:0];
 data_2 = (result[1])? data_4[3:2] : data_4[1:0];
 result[0] =~data_2[0];
 end 
 `EXE_CTO_OP:begin
 result[31:5] = 27'b0;
 result[4] = & cloz_i[15:0];
 data_15 = (result[4])? cloz_i[31:16] : cloz_i[15:0];
 result[3] = & data_15[7:0];
 data_8 = (result[3])? data_15[15:8] : data_15[7:0];
 result[2] = & data_8[3:0];
 data_4 = (result[2])? data_8[7:4] : data_8[3:0];
 result[1] = & data_4[1:0];
 data_2 = (result[1])? data_4[3:2] : data_4[1:0];
 result[0] =data_2[0];
 end 
 
   default :begin
   end 
   endcase
 end 
end 
endmodule
