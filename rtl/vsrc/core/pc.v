// `include "~/Desktop/graduation_project/vsrc/reg.v"
module pc (
    input         clk,
    input         rst,
    input         ex_pc_pc_wen,
    input  [31:0] ex_pc_pc_data,
    input         stall,

    // Branch prediction from ID stage
    input         id_pc_wen,       // ID阶段预测跳转使能
    input  [31:0] id_pc_data,      // ID阶段预测的目标PC

    output        ren,
    output [31:0] next_pc,
    output [31:0] pc_id_pc
);

  //DPI-C
  // import "DPI-C" function void get_pc_value(input int station);

  // An accepted redirect must survive instruction-memory backpressure.
  // Otherwise advance only when the current fetch request is accepted.
  wire [31:0] new_pc;
  assign new_pc = ex_pc_pc_wen ? ex_pc_pc_data :
                  stall ? next_pc :
                  id_pc_wen ? id_pc_data :
                  next_pc + 4;

  Reg #(
      .WIDTH    (32),
      .RESET_VAL(32'h8000_0000)
  ) pc_id (
      .clk (clk),
      .rst (rst),
      .din (new_pc),
      .dout(pc_id_pc),
      .wen (ren)
  );
  Reg #(
      .WIDTH    (32),
      .RESET_VAL(32'h8000_0000)
  ) pc (
      .clk (clk),
      .rst (rst),
      .din (new_pc),
      .dout(next_pc),
      .wen (ren)
  );
  Reg #(
      .WIDTH    (1),
      .RESET_VAL(1'b0)
  ) en (
      .clk (clk),
      .rst (rst),
      .din (1'b1),
      .dout(ren),
      .wen (1'b1)
  );

  // always @(*) begin
  //
  //   get_pc_value(new_pc);
  //
  // end
endmodule
