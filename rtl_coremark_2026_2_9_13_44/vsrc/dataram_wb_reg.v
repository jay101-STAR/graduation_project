`timescale 1ns / 1ns

module dataram_wb_reg (
    input clk,
    input rst,
    input stall,
    input flush,

    // Data from MEM
    input [31:0] dataram_alu_result,
    input [ 4:0] dataram_rd_addr,

    // Control from MEM
    input [3:0] dataram_aluc,
    input       dataram_rd_wen,

    // Outputs to WB stage
    output reg [31:0] wb_alu_result,
    output reg [ 4:0] wb_rd_addr,
    output reg [ 3:0] wb_aluc,
    output reg        wb_rd_wen
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset: clear all outputs
      wb_alu_result <= 32'h0;
      wb_rd_addr    <= 5'h0;
      wb_aluc       <= 4'h0;
      wb_rd_wen     <= 1'b0;
    end else if (flush) begin
      // Flush: insert bubble
      wb_alu_result <= 32'h0;
      wb_rd_addr    <= 5'h0;
      wb_aluc       <= 4'h0;
      wb_rd_wen     <= 1'b0;  // Critical: disable write
    end else if (stall) begin
      // Stall: hold current values
      wb_alu_result <= wb_alu_result;
      wb_rd_addr    <= wb_rd_addr;
      wb_aluc       <= wb_aluc;
      wb_rd_wen     <= wb_rd_wen;
    end else begin
      // Normal operation: latch inputs
      wb_alu_result <= dataram_alu_result;
      wb_rd_addr    <= dataram_rd_addr;
      wb_aluc       <= dataram_aluc;
      wb_rd_wen     <= dataram_rd_wen;
    end
  end

endmodule
