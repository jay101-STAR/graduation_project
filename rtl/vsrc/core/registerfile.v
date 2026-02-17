module chj_registerfile (
    input         clk,
    input         rst,
    input  [31:0] wdata,
    input  [ 4:0] waddr,
    input         wen,
    input         rs1_ren,
    input  [ 4:0] rs1_raddr,
    output [31:0] rs1_rdata,
    input         rs2_ren,
    input  [ 4:0] rs2_raddr,
    output [31:0] rs2_rdata,
    output [31:0] tohost_value_register
);
  registerfile #(5, 32) i0 (
      .clk                  (clk),
      .rst                  (rst),
      .wdata                (wdata),
      .waddr                (waddr),
      .wen                  (wen),
      .rs1_ren              (rs1_ren),
      .rs1_raddr            (rs1_raddr),
      .rs1_rdata            (rs1_rdata),
      .rs2_ren              (rs2_ren),
      .rs2_raddr            (rs2_raddr),
      .rs2_rdata            (rs2_rdata),
      .tohost_value_register(tohost_value_register)
  );

endmodule


module registerfile #(
    parameter addr_width = 1,
    parameter data_width = 1
) (
    input                   clk,
    input                   rst,
    input  [data_width-1:0] wdata,
    input  [addr_width-1:0] waddr,
    input                   wen,
    input                   rs1_ren,
    input  [           4:0] rs1_raddr,
    output [          31:0] rs1_rdata,
    input                   rs2_ren,
    input  [           4:0] rs2_raddr,
    output [          31:0] rs2_rdata,
    output [          31:0] tohost_value_register
);
  /* import "dpi-c" function void get_register_value(input int reg_num, input int source_value); */
  // import "dpi-c" function void set_gpr_ptr(input logic [32:0] a[]);
  reg [data_width-1:0] rf[2**addr_width-1:0];

  integer i;

  // Initialize all registers to 0 at simulation start
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      rf[i] = 0;
    end
  end

  // Synchronous write with reset
  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1) begin
        rf[i] <= 0;
      end
    end else if (wen && waddr != 0) begin
      rf[waddr] <= wdata;
    end
  end
  assign rs1_rdata = (rs1_ren && (rs1_raddr != 0)) ?
                     ((wen && (waddr == rs1_raddr)) ? wdata : rf[rs1_raddr]) : 32'b0;
  assign rs2_rdata = (rs2_ren && (rs2_raddr != 0)) ?
                     ((wen && (waddr == rs2_raddr)) ? wdata : rf[rs2_raddr]) : 32'b0;
  /* always@(*)begin */
  /* get_register_value(28,rf[28]); */
  /* end */
  // initial set_gpr_ptr(rf);  // rf为通用寄存器的二维数组变量

  assign tohost_value_register = rf[3];
endmodule
