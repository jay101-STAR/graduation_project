`timescale 1ns / 1ps
module booth (
    input  wire        a_sign,   // 0-multa is unsigned, 1-multa is signed
    input  wire        b_sign,   // 0-multb is unsigned, 1-multb is signed
    input  wire [31:0] i_multa,  // Multiplicand
    input  wire [31:0] i_multb,  // Multipler
    output      [67:0] o_pp1,
    o_pp2,
    o_pp3,
    o_pp4,
    o_pp5,
    o_pp6,
    o_pp7,
    o_pp8,
    o_pp9,
    o_pp10,
    o_pp11,
    o_pp12,
    o_pp13,
    o_pp14,
    o_pp15,
    o_pp16,
    o_pp17
);


  // sign bit extend, for unsigned operator extended by 0, for signed operator extended by orignal sign bit
  wire [ 1:0] sig_exta = ~a_sign ? 2'b00 : {2{i_multa[31]}};
  wire [ 1:0] sig_extb = ~b_sign ? 2'b00 : {2{i_multb[31]}};

  // generat -x, -2x, 2x for Booth encoding
  wire [33:0] x = {sig_exta, i_multa};
  wire [33:0] x_c = ~x + 1;  // -x, complement code of x
  wire [33:0] xm2 = x << 1;  // 2*x
  wire [33:0] x_cm2 = x_c << 1;  // -2*x

  //        18 17         [16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1]     0
  //        |---|          |------------------------------------|      |
  // extended sign bits              orignal operator             appended bit for encoding
  wire [34:0] y = {sig_extb, i_multb, 1'b0};

  // calculating partial product based on Booth Radix-4 encoding
  wire [33:0] pp                                            [16:0];
  generate
    genvar i;
    for (i = 0; i < 34; i = i + 2) begin : GEN_PP
      assign pp[i/2] = (y[i+2:i] == 3'b001 || y[i+2:i] == 3'b010) ? x     :
                     (y[i+2:i] == 3'b101 || y[i+2:i] == 3'b110) ? x_c   :
        	     (y[i+2:i] == 3'b011                      ) ? xm2   :
        	     (y[i+2:i] == 3'b100                      ) ? x_cm2 : 34'b0;
    end
  endgenerate
  assign o_pp1  = {{34{pp[0][33]}}, pp[0]};
  assign o_pp2  = {{32{pp[1][33]}}, pp[1], 2'b00};
  assign o_pp3  = {{30{pp[2][33]}}, pp[2], 4'b00};
  assign o_pp4  = {{28{pp[3][33]}}, pp[3], 6'b00};
  assign o_pp5  = {{26{pp[4][33]}}, pp[4], 8'b00};
  assign o_pp6  = {{24{pp[5][33]}}, pp[5], 10'b00};
  assign o_pp7  = {{22{pp[6][33]}}, pp[6], 12'b00};
  assign o_pp8  = {{20{pp[7][33]}}, pp[7], 14'b00};
  assign o_pp9  = {{18{pp[8][33]}}, pp[8], 16'b00};
  assign o_pp10 = {{16{pp[9][33]}}, pp[9], 18'b00};
  assign o_pp11 = {{14{pp[10][33]}}, pp[10], 20'b00};
  assign o_pp12 = {{12{pp[11][33]}}, pp[11], 22'b00};
  assign o_pp13 = {{10{pp[12][33]}}, pp[12], 24'b00};
  assign o_pp14 = {{8{pp[13][33]}}, pp[13], 26'b00};
  assign o_pp15 = {{6{pp[14][33]}}, pp[14], 28'b00};
  assign o_pp16 = {{4{pp[15][33]}}, pp[15], 30'b00};
  assign o_pp17 = {{2{pp[16][33]}}, pp[16], 32'b00};

endmodule
