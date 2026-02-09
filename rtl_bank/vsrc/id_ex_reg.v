`timescale 1ns / 1ns

module id_ex_reg (
    input clk,
    input rst,
    input stall,
    input flush,

    // Data signals from ID
    input [31:0] id_pc,
    input [31:0] id_rs1_data,
    input [31:0] id_rs2_data,
    input [ 4:0] id_rs1_addr,
    input [ 4:0] id_rs2_addr,
    input [ 4:0] id_rd_addr,
    input [31:0] id_imm,       // 立即数，用于分支地址计算

    // Control signals from ID
    input [ 3:0] id_aluc,
    input [ 7:0] id_alucex,
    input        id_rd_wen,
    input        id_is_csr,
    input [11:0] id_csr_addr,
    // 移除id_branch_taken输入，分支判断移到EX阶段

    // Branch prediction signals from ID
    input        id_branch_predicted,  // 预测是否跳转
    input [31:0] id_predicted_pc,      // 预测的目标PC
    input        id_is_branch,         // 是否是分支指令

    // Multiplier control signal from ID
    input id_is_mul_instruction,  // 是否是乘法指令

    // Divider control signal from ID
    input id_is_div_instruction,  // 是否是除法指令

    // Outputs to EX stage
    output reg [31:0] ex_pc,
    output reg [31:0] ex_rs1_data,
    output reg [31:0] ex_rs2_data,
    output reg [ 4:0] ex_rs1_addr,
    output reg [ 4:0] ex_rs2_addr,
    output reg [ 4:0] ex_rd_addr,
    output reg [31:0] ex_imm,       // 立即数，用于分支地址计算
    output reg [ 3:0] ex_aluc,
    output reg [ 7:0] ex_alucex,
    output reg        ex_rd_wen,
    output reg        ex_is_csr,
    output reg [11:0] ex_csr_addr,
    // 移除ex_branch_taken输出，分支判断在EX阶段进行

    // Branch prediction outputs to EX
    output reg        ex_branch_predicted,  // 预测是否跳转
    output reg [31:0] ex_predicted_pc,      // 预测的目标PC
    output reg        ex_is_branch,         // 是否是分支指令

    // Multiplier control output to EX
    output reg ex_is_mul_instruction,  // 是否是乘法指令

    // Divider control output to EX
    output reg ex_is_div_instruction  // 是否是除法指令
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset: clear all outputs
      ex_pc                 <= 32'h0;
      ex_rs1_data           <= 32'h0;
      ex_rs2_data           <= 32'h0;
      ex_rs1_addr           <= 5'h0;
      ex_rs2_addr           <= 5'h0;
      ex_rd_addr            <= 5'h0;
      ex_imm                <= 32'h0;
      ex_aluc               <= 4'h0;
      ex_alucex             <= 8'h0;
      ex_rd_wen             <= 1'b0;
      ex_is_csr             <= 1'b0;
      ex_csr_addr           <= 12'h0;
      // Branch prediction signals
      ex_branch_predicted   <= 1'b0;
      ex_predicted_pc       <= 32'h0;
      ex_is_branch          <= 1'b0;
      // Multiplier control signal
      ex_is_mul_instruction <= 1'b0;
      // Divider control signal
      ex_is_div_instruction <= 1'b0;
    end else if (flush) begin
      // Flush: insert bubble (NOP-like state)
      ex_pc                 <= 32'h0;
      ex_rs1_data           <= 32'h0;
      ex_rs2_data           <= 32'h0;
      ex_rs1_addr           <= 5'h0;
      ex_rs2_addr           <= 5'h0;
      ex_rd_addr            <= 5'h0;
      ex_imm                <= 32'h0;
      ex_aluc               <= 4'h0;
      ex_alucex             <= 8'h0;
      ex_rd_wen             <= 1'b0;  // Critical: disable write
      ex_is_csr             <= 1'b0;
      ex_csr_addr           <= 12'h0;
      // Branch prediction signals (clear on flush)
      ex_branch_predicted   <= 1'b0;
      ex_predicted_pc       <= 32'h0;
      ex_is_branch          <= 1'b0;
      // Multiplier control signal (clear on flush)
      ex_is_mul_instruction <= 1'b0;
      // Divider control signal (clear on flush)
      ex_is_div_instruction <= 1'b0;
    end else if (stall) begin
      // Stall: hold current values
      ex_pc                 <= ex_pc;
      ex_rs1_data           <= ex_rs1_data;
      ex_rs2_data           <= ex_rs2_data;
      ex_rs1_addr           <= ex_rs1_addr;
      ex_rs2_addr           <= ex_rs2_addr;
      ex_rd_addr            <= ex_rd_addr;
      ex_imm                <= ex_imm;
      ex_aluc               <= ex_aluc;
      ex_alucex             <= ex_alucex;
      ex_rd_wen             <= ex_rd_wen;
      ex_is_csr             <= ex_is_csr;
      ex_csr_addr           <= ex_csr_addr;
      // Branch prediction signals (hold on stall)
      ex_branch_predicted   <= ex_branch_predicted;
      ex_predicted_pc       <= ex_predicted_pc;
      ex_is_branch          <= ex_is_branch;
      // Multiplier control signal (hold on stall)
      ex_is_mul_instruction <= ex_is_mul_instruction;
      // Divider control signal (hold on stall)
      ex_is_div_instruction <= ex_is_div_instruction;
    end else begin
      // Normal operation: latch inputs
      ex_pc                 <= id_pc;
      ex_rs1_data           <= id_rs1_data;
      ex_rs2_data           <= id_rs2_data;
      ex_rs1_addr           <= id_rs1_addr;
      ex_rs2_addr           <= id_rs2_addr;
      ex_rd_addr            <= id_rd_addr;
      ex_imm                <= id_imm;
      ex_aluc               <= id_aluc;
      ex_alucex             <= id_alucex;
      ex_rd_wen             <= id_rd_wen;
      ex_is_csr             <= id_is_csr;
      ex_csr_addr           <= id_csr_addr;
      // Branch prediction signals (latch on normal operation)
      ex_branch_predicted   <= id_branch_predicted;
      ex_predicted_pc       <= id_predicted_pc;
      ex_is_branch          <= id_is_branch;
      // Multiplier control signal (latch on normal operation)
      ex_is_mul_instruction <= id_is_mul_instruction;
      // Divider control signal (latch on normal operation)
      ex_is_div_instruction <= id_is_div_instruction;
    end
  end

endmodule
