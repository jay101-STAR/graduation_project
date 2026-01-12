`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module id (
    /* input reset, */
    input  [31:0] id_inst         ,
    input  [31:0] reg_id_rs1_data ,reg_id_rs2_data ,
    input  [31:0] pc_id_pc        ,

    output [31:0] id_ex_pc        ,
    output        id_reg_rs1_ren  ,id_reg_rs2_ren  ,
    output [ 4:0] id_reg_rs1_addr ,id_reg_rs2_addr ,

    output [31:0] id_ex_rs1_data  ,id_ex_rs2_data  ,
    output        id_ex_rd_wen    ,
    output [ 4:0] id_ex_rd_addr   ,
    output [ 3:0] id_ex_aluc      ,
    output [ 7:0] id_ex_alucex    ,
    output id_ex_branch_taken     ,

    output            id_ex_is_csr,
    output [11:0] id_ex_csr_addr  ,
    output [4:0]  id_ex_rs1_addr   //csr's addr
);
  //DPI-C
  // import "DPI-C" function void ebreak(
  //   input int station,
  //   input int inst
  // );
  wire id_ex_rd_wen1;

  wire [2:0] func3 = id_inst[14:12];
  wire [6:0] op7 = id_inst[6:0];
  wire [6:0] func7 = id_inst[31:25];
  wire [3:0] inst_type;

  wire [31:0] id_ex_rs1_data_for_csr;


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
  //对于CSR指令，区分所reg_id_rs1_data还是立即数扩展
  assign id_ex_rs1_data_for_csr = id_ex_alucex[5]? {27'b0, id_reg_rs1_addr} : reg_id_rs1_data;

  /* wire [6:0] id_ex_aluc1                  ; */
  // wire [7:0] id_ex_alucex1, id_ex_alucex2;
  // 各类型的操作数
  wire [7:0] R_TYPE_EX, I_TYPE_EX;
  wire [7:0] S_TYPE_EX, B_TYPE_EX;
  wire [7:0] L_TYPE_EX, CSR_TYPE_EX;
  //下面这些指令其FUNC3和OP7完全一样，因此多判断一步,数字后缀表示其FUNC3是多少
  wire [7:0] R_TYPE_EX_000;  //判断是SUB还是ADD
  wire [7:0] R_TYPE_EX_101;  //判断是SRL还是SRA
  wire [7:0] I_TYPE_EX_101;  //判断是SRLI还算SRAI
  wire [7:0] E_TYPE_MRET_TYPE_EX_000;  //ECALL OR EBREAK OR MRET

  wire [3:0] E_TYPE_MRET_TYPE_OR_CSR_TYPE;
  assign E_TYPE_MRET_TYPE_OR_CSR_TYPE = (func3 == 3'b000)? `E_TYPE_MRET_TYPE : `CSR_TYPE;

  wire [31:0] btype_reg_ex_data1;
  wire [31:0] btype_reg_ex_data2;

  //计算rs1，rs2的关系
  wire rs1_signedlowerthan_rs2;
  wire rs1_signedbiggerthan_rs2; // 包括大于等于
  wire rs1_equal_rs2;
  wire rs1_unequal_rs2;
  wire rs1_unsignedlowerthan_rs2;
  wire rs1_unsignedbigerthan_rs2;

  assign rs1_signedlowerthan_rs2   = ($signed(reg_id_rs1_data) < $signed(reg_id_rs2_data));
  assign rs1_signedbiggerthan_rs2  = (~rs1_signedlowerthan_rs2);
  assign rs1_unsignedlowerthan_rs2 = (reg_id_rs1_data < reg_id_rs2_data);
  assign rs1_unsignedbigerthan_rs2 = (~rs1_signedlowerthan_rs2);
  assign rs1_equal_rs2             = (reg_id_rs1_data == reg_id_rs2_data);
  assign rs1_unequal_rs2           = (~rs1_equal_rs2);
  //标志btype指令是否跳转，1表示跳，0表示不跳转

  assign R_TYPE_EX_000 = id_inst[30] ? `SUB_TYPE : `ADD_TYPE;
  assign R_TYPE_EX_101 = id_inst[30] ? `SRL_TYPE : `SRA_TYPE;
  assign I_TYPE_EX_101 = id_inst[30] ? `SRL_TYPE : `SRA_TYPE;
  assign E_TYPE_MRET_TYPE_EX_000 = ((id_inst[21:20] == 2'b00) ? `ECALL_TYPE  :
                                    (id_inst[21:20] == 2'b01) ? `EBREAK_TYPE :
                                    (id_inst[21:20] == 2'b10) ? `MRET_TYPE   : 8'b0) ;

  assign id_ex_rs1_addr = id_inst[19:15];
  assign id_reg_rs1_addr = id_inst[19:15];
  assign id_reg_rs2_addr = id_inst[24:20];
  assign id_ex_rd_addr   = id_inst[11:7] ;

  assign id_ex_is_csr = (inst_type == `CSR_TYPE);
  //传递pc值
  assign id_ex_pc = pc_id_pc;


  muxwithdefault #(6, 8, 1) btype_jump1 (
      id_ex_branch_taken,
      id_ex_alucex,
      1'b0,
      {
        `BEQ_TYPE  ,rs1_equal_rs2             ,
        `BNE_TYPE  ,rs1_unequal_rs2           ,
        `BLT_TYPE  ,rs1_signedlowerthan_rs2   ,
        `BGE_TYPE  ,rs1_signedbiggerthan_rs2  ,
        `BLTU_TYPE ,rs1_unsignedlowerthan_rs2 ,
        `BGEU_TYPE ,rs1_unsignedbigerthan_rs2
      }
  );
    //blt's data1 and data2
  assign btype_reg_ex_data1 = id_ex_branch_taken? sign_extended_immB : 32'd4;
  assign btype_reg_ex_data2 = pc_id_pc;


  muxwithdefault #(11, 7, 4) i1 (
      inst_type,
      op7,
      `NO_TYPE,
      {
        7'b0110011 ,`R_TYPE                      ,
        7'b0010011 ,`I_TYPE                      ,
        7'b1101111 ,`JAL_TYPE                    ,
        7'b0100011 ,`S_TYPE                      ,
        7'b0000011 ,`L_TYPE                      ,
        7'b1100011 ,`B_TYPE                      ,
        7'b1100111 ,`JALR_TYPE                   ,
        7'b0110111 ,`LUI_TYPE                    ,
        7'b0010111 ,`AUIPC_TYPE                  ,
        7'b1110011 ,E_TYPE_MRET_TYPE_OR_CSR_TYPE ,
        7'b0001111 ,`FENCE_TYPE
      }
  );
  assign id_ex_aluc = inst_type;
  muxwithdefault #(8, 4, 1) i2 (
      id_reg_rs1_ren,
      inst_type,
      1'b0,
      {
        `R_TYPE     ,1'b1 ,
        `I_TYPE     ,1'b1 ,
        `B_TYPE     ,1'b1 ,
        `JAL_TYPE   ,1'b0 ,
        `JALR_TYPE  ,1'b1 ,
        `LUI_TYPE   ,1'b0 ,
        `AUIPC_TYPE ,1'b0 ,
        `CSR_TYPE   ,1'b1
      }
  );
  muxwithdefault #(7, 4, 1) i3 (
      id_reg_rs2_ren,
      inst_type,
      1'b0,
      {
        `R_TYPE     ,1'b1 ,
        `I_TYPE     ,1'b0 ,
        `B_TYPE     ,1'b1 ,
        `JAL_TYPE   ,1'b0 ,
        `JALR_TYPE  ,1'b0 ,
        `LUI_TYPE   ,1'b0 ,
        `AUIPC_TYPE ,1'b0
      }
  );
  muxwithdefault #(8, 4, 32) i4 (
      id_ex_rs1_data,
      inst_type,
      32'b0,
      {
        `R_TYPE     ,reg_id_rs1_data    ,
        `I_TYPE     ,reg_id_rs1_data    ,
        `B_TYPE     ,btype_reg_ex_data1 ,
        `JALR_TYPE  ,reg_id_rs1_data    ,
        `JAL_TYPE   ,sign_extended_immJ ,
        `LUI_TYPE   ,low_extended_immU  ,
        `AUIPC_TYPE ,low_extended_immU  ,
        `CSR_TYPE   ,id_ex_rs1_data_for_csr
      }
  );
  muxwithdefault #(8, 4, 32) i5 (
      id_ex_rs2_data,
      inst_type,
      32'b0,
      {
        `R_TYPE     ,reg_id_rs2_data    ,
        `I_TYPE     ,sign_extended_immI ,
        `B_TYPE     ,btype_reg_ex_data2 ,
        `JALR_TYPE  ,sign_extended_immI ,
        `JAL_TYPE   ,pc_id_pc           ,
        `LUI_TYPE   ,32'b0              ,
        `AUIPC_TYPE ,pc_id_pc           ,
        `CSR_TYPE   ,32'b0

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
  // muxwithdefault #(1, 3, 8) i8 (
  //     id_ex_alucex1,
  //     func3,
  //     8'b0,
  //     {
  //       `ADD_INST,
  //       `ADD_TYPE,  //include ADD,ADDI
  //       `SLL_INST,
  //       `SLL_TYPE  //include SLL,SLLI
  //     }
  // );
  // muxwithdefault #(1, 7, 8) i9 (
  //     id_ex_alucex2,
  //     func7,
  //     8'b0,
  //     {`R_ASA_INST, id_ex_alucex1}
  // );
  // for id_ex_alucex
  muxwithdefault #(8, 3, 8) R_TYPE_FUNC3 (
      R_TYPE_EX,
      func3,
      8'b0,
      {
        `ADD_SUB_INST ,R_TYPE_EX_000 ,
        `SLL_INST     ,`SLL_TYPE     ,
        `SLT_INST     ,`SLT_TYPE     ,
        `SLTU_INST    ,`SLTU_TYPE    ,
        `XOR_INST     ,`XOR_TYPE     ,
        `SRL_SRA_INST ,R_TYPE_EX_101 ,
        `OR_INST      ,`OR_TYPE      ,
        `AND_INST     ,`AND_TYPE

      }
  );

  muxwithdefault #(8, 3, 8) I_TYPE_FUNC3 (
      I_TYPE_EX,
      func3,
      8'b0,
      {
        `ADDI_INST      ,`ADD_TYPE     ,
        `SLLI_INST      ,`SLL_TYPE     ,
        `SLTI_INST      ,`SLT_TYPE     ,
        `SLTIU_INST     ,`SLTU_TYPE    ,
        `XORI_INST      ,`XOR_TYPE     ,
        `SRLI_SRAI_INST ,I_TYPE_EX_101 ,
        `ORI_INST       ,`OR_TYPE      ,
        `ANDI_INST      ,`AND_TYPE

      }
  );

  muxwithdefault #(3, 3, 8) S_TYPE_FUNC3 (
      S_TYPE_EX,
      func3,
      8'b0,
      {
        `SB_INST, `SB_TYPE,
        `SH_INST, `SH_TYPE,
        `SW_INST, `SW_TYPE

      }
  );

  muxwithdefault #(6, 3, 8) B_TYPE_FUNC3 (
      B_TYPE_EX,
      func3,
      8'b0,
      {
        `BEQ_INST  ,`BEQ_TYPE  ,
        `BNE_INST  ,`BNE_TYPE  ,
        `BLT_INST  ,`BLT_TYPE  ,
        `BGE_INST  ,`BGE_TYPE  ,
        `BLTU_INST ,`BLTU_TYPE ,
        `BGEU_INST ,`BGEU_TYPE

      }
  );

  muxwithdefault #(5, 3, 8) L_TYPE_FUNC3 (
      L_TYPE_EX,
      func3,
      8'b0,
      {
        `LB_INST  ,`LB_TYPE  ,
        `LH_INST  ,`LH_TYPE  ,
        `LW_INST  ,`LW_TYPE  ,
        `LBU_INST ,`LBU_TYPE ,
        `LHU_INST ,`LHU_TYPE

      }
  );


  muxwithdefault #(6, 3, 8) CSR_TYPE_FUNC3 (
      CSR_TYPE_EX,
      func3,
      8'b0,
      {
        `CSRRW_INST        ,`CSRRW_TYPE             ,
        `CSRRS_INST        ,`CSRRS_TYPE             ,
        `CSRRC_INST        ,`CSRRC_TYPE             ,
        `CSRRWI_INST       ,`CSRRWI_TYPE            ,
        `CSRRSI_INST       ,`CSRRSI_TYPE            ,
        `CSRRCI_INST       ,`CSRRCI_TYPE
      }
  );

  muxwithdefault #(12, 4, 8) i15 (
      id_ex_alucex,
      inst_type,
      8'b0,
      {
        `R_TYPE           ,R_TYPE_EX               ,
        `I_TYPE           ,I_TYPE_EX               ,
        `S_TYPE           ,S_TYPE_EX               ,
        `B_TYPE           ,B_TYPE_EX               ,
        `L_TYPE           ,L_TYPE_EX               ,
        `CSR_TYPE         ,CSR_TYPE_EX             ,
        `E_TYPE_MRET_TYPE ,E_TYPE_MRET_TYPE_EX_000 ,
        `JAL_TYPE         ,`JALL_TYPE              ,
        `JALR_TYPE        ,`JALRR_TYPE             ,
        `LUI_TYPE         ,`LUII_TYPE              ,
        `AUIPC_TYPE       ,`AUIPCC_TYPE            ,
        `FENCE_TYPE       ,`FENCEE_TYPE
      }
  );


// for id_ex_rd_wen
  muxwithdefault #(8, 4, 1) i11 (
      id_ex_rd_wen1,
      inst_type,
      1'b0,
      {
        `R_TYPE     ,1'b1 ,
        `I_TYPE     ,1'b1 ,
        `B_TYPE     ,1'b0 ,
        `JAL_TYPE   ,1'b1 ,
        `JALR_TYPE  ,1'b1 ,
        `LUI_TYPE   ,1'b1 ,
        `AUIPC_TYPE ,1'b1 ,
        `CSR_TYPE   ,1'b1
      }
  );
  assign id_ex_rd_wen = (id_ex_rd_addr == 5'b0) ? 1'b0 : id_ex_rd_wen1;  //if rd = x0,not write

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

