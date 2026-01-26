`timescale 1ns / 1ps
module mul (
    input  [31:0] mul_a_i,
    input  [31:0] mul_b_i,
    input         mul_sign,
    input         mul_we,
    output [67:0] mul_result_o
);

  wire [31:0] a_i, b_i;
  wire [67:0] mul1;
  wire [68:0]out11,out12,out21,out22,out31,out32,out41,out42,out51,out52,out61,out62,out71,out72;
  wire [67:0]out13,out14,out23,out24,out33,out34,out43,out44,out53,out54,out63,out64,out73,out74;
  wire [67:0] re1, re2;
  wire [67:0]pp1,pp2,pp3,pp4,pp5,pp6,pp7,pp8,pp9,pp10,pp11,pp12,pp13,pp14,pp15,pp16,pp17;
  wire cout_0;

  assign a_i          = mul_we ? mul_a_i : 32'bx;
  assign b_i          = mul_we ? mul_b_i : 32'bx;
  assign mul_result_o = mul_we ? mul1 : 68'bx;
  booth booth1 (
      .a_sign (mul_sign),
      .b_sign (mul_sign),
      .i_multa(a_i),
      .i_multb(b_i),
      .o_pp1  (pp1),
      .o_pp2  (pp2),
      .o_pp3  (pp3),
      .o_pp4  (pp4),
      .o_pp5  (pp5),
      .o_pp6  (pp6),
      .o_pp7  (pp7),
      .o_pp8  (pp8),
      .o_pp9  (pp9),
      .o_pp10 (pp10),
      .o_pp11 (pp11),
      .o_pp12 (pp12),
      .o_pp13 (pp13),
      .o_pp14 (pp14),
      .o_pp15 (pp15),
      .o_pp16 (pp16),
      .o_pp17 (pp17)
  );
  compress compress1 (
      .in1 (pp1),
      .in2 (pp2),
      .in3 (pp3),
      .in4 (pp4),
      .cin (1'b0),
      .out1(out11),
      .out2(out12),
      .cout(cout_0)
  );
  compress compress2 (
      .in1 (pp5),
      .in2 (pp6),
      .in3 (pp7),
      .in4 (pp8),
      .cin (1'b0),
      .out1(out21),
      .out2(out22),
      .cout(cout_0)
  );
  compress compress3 (
      .in1 (pp9),
      .in2 (pp10),
      .in3 (pp11),
      .in4 (pp12),
      .cin (1'b0),
      .out1(out31),
      .out2(out32),
      .cout(cout_0)
  );
  compress compress4 (
      .in1 (pp13),
      .in2 (pp14),
      .in3 (pp15),
      .in4 (pp16),
      .cin (1'b0),
      .out1(out41),
      .out2(out42),
      .cout(cout_0)
  );
  compress compress5 (
      .in1 (out13),
      .in2 (out14),
      .in3 (out23),
      .in4 (out24),
      .cin (1'b0),
      .out1(out51),
      .out2(out52),
      .cout(cout_0)
  );
  compress compress6 (
      .in1 (out33),
      .in2 (out34),
      .in3 (out43),
      .in4 (out44),
      .cin (1'b0),
      .out1(out61),
      .out2(out62),
      .cout(cout_0)
  );
  compress compress7 (
      .in1 (out53),
      .in2 (out54),
      .in3 (out63),
      .in4 (out64),
      .cin (1'b0),
      .out1(out71),
      .out2(out72),
      .cout(cout_0)
  );

  full_adder full_adder1 (
      .a (out73),
      .b (out74),
      .ci(pp17),
      .s (re1),
      .co(re2)
  );
  assign out13[67:0] = out11[67:0] << 1'b1;
  assign out14       = out12[67:0];
  assign out23[67:0] = out21[67:0] << 1'b1;
  assign out24       = out22[67:0];
  assign out33[67:0] = out31[67:0] << 1'b1;
  assign out34       = out32[67:0];
  assign out43[67:0] = out41[67:0] << 1'b1;
  assign out44       = out42[67:0];
  assign out53[67:0] = out51[67:0] << 1'b1;
  assign out54       = out52[67:0];
  assign out63[67:0] = out61[67:0] << 1'b1;
  assign out64       = out62[67:0];
  assign out73[67:0] = out71[67:0] << 1'b1;
  assign out74       = out72[67:0];

  assign mul1        = re1 + re2;
  integer i;

endmodule
