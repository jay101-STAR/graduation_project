`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

// `include "muxwithdefault.v"
module id (
    /* input reset, */
    input  [31:0] id_inst,
    input  [31:0] reg_id_rs1_data,
    reg_id_rs2_data,
    input  [31:0] pc_id_pc,
    output [31:0] id_ex_pc,
    output        id_reg_rs1_ren,
    id_reg_rs2_ren,
    output [ 4:0] id_reg_rs1_addr,
    id_reg_rs2_addr,
    output [31:0] id_ex_rs1_data,
    id_ex_rs2_data,
    output        id_ex_rd_wen,
    output [ 4:0] id_ex_rd_addr,
    output [ 3:0] id_ex_aluc,
    output [ 7:0] id_ex_alucex
);
  //DPI-C
  // import "DPI-C" function void ebreak(
  //   input int station,
  //   input int inst
  // );

  wire [ 2:0] func3 = id_inst[14:12];
  wire [ 6:0] op7 = id_inst[6:0];
  wire [ 6:0] func7 = id_inst[31:25];
  wire [ 3:0] inst_type;

  //12位立即数扩展,为高位有符号扩展
  wire [11:0] immI = id_inst[31:20];
  wire [31:0] sign_extended_immI = {{20{immI[11]}}, immI[11:0]};
  //12 位立即数扩展，为高位有符号扩展，为低位零扩展
  wire [11:0] immB = {id_inst[31], id_inst[7], id_inst[30:25], id_inst[11:8]};
  wire [31:0] sign_extended_immB = {{19{immB[11]}}, immB[11:0], 1'b0};
  //20位立即数扩展,为低位零扩展
  wire [19:0] immU = id_inst[31:12];
  wire [31:0] low_extended_immU = {immU[19:0], 12'b0};
  //20位有符号扩展，低位置0
  wire [19:0] immJ = {id_inst[31], id_inst[19:12], id_inst[20], id_inst[30:21]};
  wire [31:0] sign_extended_immJ = {{11{immJ[19]}}, immJ[19:0], 1'b0};
  /* wire [6:0] id_ex_aluc1                  ; */
  wire [7:0] id_ex_alucex1, id_ex_alucex2;
  assign id_reg_rs1_addr = id_inst[19:15];
  assign id_reg_rs2_addr = id_inst[24:20];
  assign id_ex_rd_addr = id_inst[11:7];

  //传递pc值
  assign id_ex_pc = pc_id_pc;

  muxwithdefault #(11, 7, 4) i1 (
      inst_type,
      op7,
      `NO_TYPE,
      {
        7'b0110011,
        `R_TYPE,
        7'b0010011,
        `I_TYPE,
        7'b1101111,
        `J_TYPE,
        7'b0100011,
        `S_TYPE,
        7'b0000011,
        `L_TYPE,
        7'b1100011,
        `B_TYPE,
        7'b1100111,
        `JALR_TYPE,
        7'b0110111,
        `LUI_TYPE,
        7'b0010111,
        `AUIPC_TYPE,
        7'b1110011,
        `E_TYPE_ZICSR_TYPE,
        7'b0001111,
        `FENCE_TYPE
      }
  );
  assign id_ex_aluc = inst_type;
  muxwithdefault #(7, 4, 1) i2 (
      id_reg_rs1_ren,
      inst_type,
      1'b0,
      {
        `R_TYPE,
        1'b1,
        `I_TYPE,
        1'b1,
        `B_TYPE,
        1'b1,
        `J_TYPE,
        1'b0,
        `JALR_TYPE,
        1'b1,
        `LUI_TYPE,
        1'b0,
        `AUIPC_TYPE,
        1'b0
      }
  );
  muxwithdefault #(7, 4, 1) i3 (
      id_reg_rs2_ren,
      inst_type,
      1'b0,
      {
        `R_TYPE,
        1'b1,
        `I_TYPE,
        1'b0,
        `B_TYPE,
        1'b1,
        `J_TYPE,
        1'b0,
        `JALR_TYPE,
        1'b0,
        `LUI_TYPE,
        1'b0,
        `AUIPC_TYPE,
        1'b0
      }
  );
  muxwithdefault #(6, 4, 32) i4 (
      id_ex_rs1_data,
      inst_type,
      32'b0,
      {
        `R_TYPE,
        reg_id_rs1_data,
        `I_TYPE,
        reg_id_rs1_data,
        `JALR_TYPE,
        reg_id_rs1_data,
        `J_TYPE,
        sign_extended_immJ,
        `LUI_TYPE,
        low_extended_immU,
        `AUIPC_TYPE,
        low_extended_immU
      }
  );
  muxwithdefault #(6, 4, 32) i5 (
      id_ex_rs2_data,
      inst_type,
      32'b0,
      {
        `R_TYPE,
        reg_id_rs2_data,
        `I_TYPE,
        sign_extended_immI,
        `JALR_TYPE,
        sign_extended_immI,
        `J_TYPE,
        pc_id_pc,
        `LUI_TYPE,
        32'b0,
        `AUIPC_TYPE,
        pc_id_pc
      }
  );
  //判断一个R_TYPE指令是属于ASA还是SUA
  /* muxwithdefault #(2,7,7)  i6 (id_ex_aluc1,func7,7'b0,{ */
  /* `R_ASA_INST,`R_ASA_TYPE, */
  /* `R_SUA_INST,`R_SUA_TYPE */
  /* }); */
  /* muxwithdefault #(1,3,7) i7 (id_ex_aluc,inst_type,7'b0,{ */
  /* `R_TYPE,id_ex_aluc1 */
  /* }); */
  //判断R_TYPE,I_TYPE指令具体属于哪一个指令如，ADD，ADDI等 
  //如果所R-TYPE,需要判断三次，即要判断到alucex2，如果所I-TYPE只需要判断两次，即判断到alucex1
  muxwithdefault #(1, 3, 8) i8 (
      id_ex_alucex1,
      func3,
      8'b0,
      {
        `ADD_INST,
        `ADD_TYPE,  //include ADD,ADDI
        `SLL_INST,
        `SLL_TYPE  //include SLL,SLLI
      }
  );
  muxwithdefault #(1, 7, 8) i9 (
      id_ex_alucex2,
      func7,
      8'b0,
      {`R_ASA_INST, id_ex_alucex1}
  );
  muxwithdefault #(6, 4, 8) i10 (
      id_ex_alucex,
      inst_type,
      8'b0,
      {
        `R_TYPE,
        id_ex_alucex2,
        `I_TYPE,
        id_ex_alucex1,
        `J_TYPE,
        `JAL_TYPE,
        `JALR_TYPE,
        `JALRR_TYPE,
        `LUI_TYPE,
        `LUII_TYPE,
        `AUIPC_TYPE,
        `AUIPCC_TYPE
      }
  );
  muxwithdefault #(7, 4, 1) i11 (
      id_ex_rd_wen,
      inst_type,
      1'b0,
      {
        `R_TYPE,
        1'b1,
        `I_TYPE,
        1'b1,
        `B_TYPE,
        1'b0,
        `J_TYPE,
        1'b1,
        `JALR_TYPE,
        1'b1,
        `LUI_TYPE,
        1'b1,
        `AUIPC_TYPE,
        1'b1
      }
  );

  /* reg  ebreak_called = 0; */
  /* reg ebreak_triggered = 0; */

  // always @(*) begin
  //   if (inst_type == `I_TYPE_E_TYPE) begin
  //     if (func3 == 3'b000) begin
  //       ebreak(`HIT_TRAP, id_inst);
  //     end else begin
  //       ebreak(`HIT_BAD_TRAP, id_inst);
  //     end
  //   end
  // end




endmodule

