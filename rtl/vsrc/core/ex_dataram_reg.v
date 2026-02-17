`timescale 1ns / 1ns

module ex_dataram_reg (
    input clk,
    input rst,
    input stall,
    input flush,

    // Data from EX
    input [31:0] ex_alu_result,
    input [31:0] ex_dataram_addr,
    input [31:0] ex_dataram_wdata,
    input [ 4:0] ex_rd_addr,

    // Control from EX
    input [3:0] ex_aluc,
    input [7:0] ex_alucex,
    input       ex_rd_wen,
    input       ex_dataram_wen,
    input       ex_dataram_ren,

    // Outputs to MEM stage
    output reg [31:0] dataram_alu_result,
    output reg [31:0] dataram_addr,
    output reg [31:0] dataram_wdata,
    output reg [ 4:0] dataram_rd_addr,
    output reg [ 3:0] dataram_aluc,
    output reg [ 7:0] dataram_alucex,
    output reg        dataram_rd_wen,
    output reg        dataram_wen,
    output reg        dataram_ren
);

  always @(posedge clk) begin
    if (rst) begin
      // Reset: clear all outputs
      dataram_alu_result <= 32'h0;
      dataram_addr       <= 32'h0;
      dataram_wdata      <= 32'h0;
      dataram_rd_addr    <= 5'h0;
      dataram_aluc       <= 4'h0;
      dataram_alucex     <= 8'h0;
      dataram_rd_wen     <= 1'b0;
      dataram_wen        <= 1'b0;
      dataram_ren        <= 1'b0;
    end else if (flush) begin
      // Flush: insert bubble
      dataram_alu_result <= 32'h0;
      dataram_addr       <= 32'h0;
      dataram_wdata      <= 32'h0;
      dataram_rd_addr    <= 5'h0;
      dataram_aluc       <= 4'h0;
      dataram_alucex     <= 8'h0;
      dataram_rd_wen     <= 1'b0;  // Critical: disable write
      dataram_wen        <= 1'b0;
      dataram_ren        <= 1'b0;
    end else if (stall) begin
      // Stall: hold current values
      dataram_alu_result <= dataram_alu_result;
      dataram_addr       <= dataram_addr;
      dataram_wdata      <= dataram_wdata;
      dataram_rd_addr    <= dataram_rd_addr;
      dataram_aluc       <= dataram_aluc;
      dataram_alucex     <= dataram_alucex;
      dataram_rd_wen     <= dataram_rd_wen;
      dataram_wen        <= dataram_wen;
      dataram_ren        <= dataram_ren;
    end else begin
      // Normal operation: latch inputs
      dataram_alu_result <= ex_alu_result;
      dataram_addr       <= ex_dataram_addr;
      dataram_wdata      <= ex_dataram_wdata;
      dataram_rd_addr    <= ex_rd_addr;
      dataram_aluc       <= ex_aluc;
      dataram_alucex     <= ex_alucex;
      dataram_rd_wen     <= ex_rd_wen;
      dataram_wen        <= ex_dataram_wen;
      dataram_ren        <= ex_dataram_ren;
    end
  end

endmodule
