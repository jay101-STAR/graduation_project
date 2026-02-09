`timescale 1ns / 1ns

module if_id_reg (
    input clk,
    input rst,
    input stall,  // 暂停：保持当前值
    input flush,  // 冲刷：清零（插入气泡）

    // Inputs from IF stage
    input [31:0] if_pc,
    input [31:0] if_instruction,

    // Outputs to ID stage
    output reg [31:0] id_pc,
    output reg [31:0] id_instruction
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset: clear all outputs
      id_pc          <= 32'h0;
      id_instruction <= 32'h0000_0013;  // NOP (addi x0, x0, 0)
    end else if (flush) begin
      // Flush: insert bubble (NOP)
      id_pc          <= 32'h0;
      id_instruction <= 32'h0000_0013;  // NOP
    end else if (stall) begin
      // Stall: hold current values (do nothing)
      id_pc          <= id_pc;
      id_instruction <= id_instruction;
    end else begin
      // Normal operation: latch inputs
      id_pc          <= if_pc;
      id_instruction <= if_instruction;
    end
  end

endmodule
