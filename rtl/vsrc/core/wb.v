`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module wb (
    input  [31:0] ex_wb_alu_result,
    input  [ 4:0] ex_wb_rd_addr,
    input         ex_wb_rd_wen,
    input  [ 3:0] ex_wb_aluc,
    input  [31:0] dataram_wb_rdata,

    output [31:0] wb_reg_rd_data,
    output [ 4:0] wb_reg_rd_addr,
    output        wb_reg_rd_wen
);

  // Select final write-back data
  muxwithdefault #(8, 4, 32) wb_data_mux (
      wb_reg_rd_data,
      ex_wb_aluc,
      32'b0,
      {
        `R_TYPE     ,ex_wb_alu_result ,
        `I_TYPE     ,ex_wb_alu_result ,
        `LUI_TYPE   ,ex_wb_alu_result ,
        `AUIPC_TYPE ,ex_wb_alu_result ,
        `JAL_TYPE   ,ex_wb_alu_result ,
        `JALR_TYPE  ,ex_wb_alu_result ,
        `CSR_TYPE   ,ex_wb_alu_result ,
        `L_TYPE     ,dataram_wb_rdata
      }
  );

  // Pass through control signals
  assign wb_reg_rd_addr = ex_wb_rd_addr;
  assign wb_reg_rd_wen  = ex_wb_rd_wen;

endmodule
