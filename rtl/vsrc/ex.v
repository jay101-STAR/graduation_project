`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
// `include "/home/jay/Desktop/graduation_project/vsrc/muxwithdefault.v"
module ex (
    input [3:0] id_ex_aluc,
    input [7:0] id_ex_alucex,
    input [4:0] id_ex_rd_addr,
    input id_ex_rd_wen,
    input [31:0] id_ex_rs1_data,
    id_ex_rs2_data,
    input [31:0] id_ex_pc,
    output [31:0] ex_reg_rd_data,
    output [4:0] ex_reg_rd_addr,
    output ex_reg_rd_wen,
    output ex_pc_pc_wen,
    output [31:0] ex_pc_pc_data

);
  wire [31:0] ex_reg_rd_data1;
  wire [31:0] result_add = id_ex_rs1_data + id_ex_rs2_data;
  wire [31:0] pc_plus_4 = id_ex_pc + 4;
  //得到修改的pc的值
  muxwithdefault #(2, 4, 1) i0 (
      ex_pc_pc_wen,
      id_ex_aluc,
      1'b0,
      {`J_TYPE, 1'b1, `JALR_TYPE, 1'b1}
  );
  muxwithdefault #(2, 4, 32) i00 (
      ex_pc_pc_data,
      id_ex_aluc,
      pc_plus_4,
      {`J_TYPE, result_add, `JALR_TYPE, {result_add[31:1], 1'b0}}
  );
  //得出rd_data的值
  muxwithdefault #(5, 8, 32) i1 (
      ex_reg_rd_data1,
      id_ex_alucex,
      32'b0,
      {
        `ADD_TYPE,
        result_add,
        `AUIPCC_TYPE,
        result_add,
        `LUII_TYPE,
        id_ex_rs1_data,  //immU
        `JAL_TYPE,
        pc_plus_4,
        `JALRR_TYPE,
        pc_plus_4
      }
  );
  muxwithdefault #(6, 4, 32) i2 (
      ex_reg_rd_data,
      id_ex_aluc,
      32'b0,
      {
        `R_TYPE,
        ex_reg_rd_data1,
        `I_TYPE,
        ex_reg_rd_data1,
        `LUI_TYPE,
        ex_reg_rd_data1,
        `AUIPC_TYPE,
        ex_reg_rd_data1,
        `J_TYPE,
        ex_reg_rd_data1,
        `JALR_TYPE,
        ex_reg_rd_data1
      }
  );
  //将wen,addr的值传递给regfile
  muxwithdefault #(6, 4, 1) i3 (
      ex_reg_rd_wen,
      id_ex_aluc,
      1'b0,
      {
        `R_TYPE,
        id_ex_rd_wen,
        `I_TYPE,
        id_ex_rd_wen,
        `J_TYPE,
        id_ex_rd_wen,
        `JALR_TYPE,
        id_ex_rd_wen,
        `LUI_TYPE,
        id_ex_rd_wen,
        `AUIPC_TYPE,
        id_ex_rd_wen
      }
  );
  muxwithdefault #(6, 4, 5) i4 (
      ex_reg_rd_addr,
      id_ex_aluc,
      5'b0,
      {
        `R_TYPE,
        id_ex_rd_addr,
        `I_TYPE,
        id_ex_rd_addr,
        `J_TYPE,
        id_ex_rd_addr,
        `JALR_TYPE,
        id_ex_rd_addr,
        `LUI_TYPE,
        id_ex_rd_addr,
        `AUIPC_TYPE,
        id_ex_rd_addr
      }
  );

endmodule
