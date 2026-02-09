`timescale 1ns / 1ps
module compress (
    input  [67:0] in1,
    in2,
    in3,
    in4,
    input         cin,
    output [68:0] out1,
    output [68:0] out2,
    output        cout

);
  wire [67:0] w1, w2, w3;

  assign w1   = in1 ^ in2 ^ in3 ^ in4;
  assign w2   = (in1 & in2) | (in3 & in4);
  assign w3   = (in1 | in2) & (in3 | in4);

  assign out2 = {w1[19], w1} ^ {w3, cin};
  assign cout = w3[67];
  assign out1 = ({w1[19], w1} & {w3, cin}) | ((~{w1[19], w1}) & {w2[19], w2});
endmodule
