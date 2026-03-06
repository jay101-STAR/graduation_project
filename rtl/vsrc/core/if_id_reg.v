`timescale 1ns / 1ns

module if_id_reg (
    input clk,
    input rst,
    input stall,  // 暂停：保持当前值
    input flush,  // 冲刷：清零（插入气泡）

    // Inputs from IF stage
    input [31:0] if_pc,
    input [31:0] if_instruction,
    input        if_valid,
    input        if_predicted_taken,
    input [31:0] if_predicted_pc,
    input [ 9:0] if_predicted_pht_index,

    // Outputs to ID stage
    output reg [31:0] id_pc,
    output reg [31:0] id_instruction,
    output reg        id_valid,
    output reg        id_predicted_taken,
    output reg [31:0] id_predicted_pc,
    output reg [ 9:0] id_predicted_pht_index
);

  always @(posedge clk) begin
    if (rst) begin
      // Reset: clear all outputs
      id_pc          <= 32'h0;
      id_instruction <= 32'h0000_0013;  // NOP (addi x0, x0, 0)
      id_valid       <= 1'b0;
      id_predicted_taken <= 1'b0;
      id_predicted_pc <= 32'h0;
      id_predicted_pht_index <= 10'h0;
    end else if (flush) begin
      // Flush: insert bubble (NOP)
      id_pc          <= 32'h0;
      id_instruction <= 32'h0000_0013;  // NOP
      id_valid       <= 1'b0;
      id_predicted_taken <= 1'b0;
      id_predicted_pc <= 32'h0;
      id_predicted_pht_index <= 10'h0;
    end else if (stall) begin
      // Stall: hold current values (do nothing)
      id_pc          <= id_pc;
      id_instruction <= id_instruction;
      id_valid       <= id_valid;
      id_predicted_taken <= id_predicted_taken;
      id_predicted_pc <= id_predicted_pc;
      id_predicted_pht_index <= id_predicted_pht_index;
    end else begin
      // Normal operation: latch inputs
      id_pc          <= if_pc;
      id_instruction <= if_instruction;
      id_valid       <= if_valid;
      id_predicted_taken <= if_predicted_taken;
      id_predicted_pc <= if_predicted_pc;
      id_predicted_pht_index <= if_predicted_pht_index;
    end
  end

endmodule
