module compare (
    input  [31:0] r1,
    input  [31:0] r2,
    input         we,
    input         sign,
    output        result

);

  assign result = (~we) ? 1'bx : (sign ? (((r1[31])&&(!r2[31])) ||
                    ((r1[31] == r2[31])&&(r1 < r2)) )
                   : (r1 < r2) );

endmodule
