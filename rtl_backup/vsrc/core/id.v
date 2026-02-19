`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module id (
    /* input reset, */
    input  [31:0] id_inst         ,
    input  [31:0] reg_id_rs1_data ,reg_id_rs2_data ,
    input  [31:0] pc_id_pc        ,
    input         id_if_predicted_taken,
    input  [31:0] id_if_predicted_pc,

    output        id_reg_rs1_ren  ,id_reg_rs2_ren  ,
    output [ 4:0] id_reg_rs1_addr ,id_reg_rs2_addr ,

    output [31:0] id_ex_rs1_data  ,id_ex_rs2_data  ,
    output        id_ex_rd_wen    ,
    output [ 4:0] id_ex_rd_addr   ,
    output [ 3:0] id_ex_aluc      ,
    output [ 7:0] id_ex_alucex    ,
    // 移除id_ex_branch_taken输出，分支判断移到EX阶段
    output [31:0] id_ex_imm       ,  // 立即数，用于分支地址计算

    output            id_ex_is_csr,
    output [11:0]   id_ex_csr_addr,

    // Branch prediction outputs
    output            id_branch_predicted,  // 预测是否跳转
    output [31:0]     id_predicted_pc,      // 预测的目标PC
    output            id_is_branch,         // 是否是分支指令

    // Multiplier control signal
    output            id_ex_is_mul_instruction,  // 是否是乘法指令

    // Divider control signal
    output            id_ex_is_div_instruction   // 是否是除法指令
);
  //DPI-C
  // import "DPI-C" function void ebreak(
  //   input int station,
  //   input int inst
  // );
  wire id_ex_rd_wen1;

  wire [2:0] func3 = id_inst[14:12];
  wire [6:0] op7 = id_inst[6:0];
  wire [3:0] inst_type;

  // wire [31:0] id_ex_rs1_data_for_csr;


  //12位立即数扩展,为高位有符号扩展
  wire [11:0] immI = id_inst[31:20];
  wire [31:0] sign_extended_immI = {{20{immI[11]}}, immI[11:0]};
  //S型立即数扩展
  wire [11:0] immS = {id_inst[31:25], id_inst[11:7]};
  wire [31:0] sign_extended_immS = {{20{immS[11]}}, immS[11:0]};
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
  // assign id_ex_rs1_data_for_csr = id_ex_alucex[5]? {27'b0, id_reg_rs1_addr} : reg_id_rs1_data;

  /* wire [6:0] id_ex_aluc1                  ; */
  // wire [7:0] id_ex_alucex1, id_ex_alucex2;
  // 各类型的操作数
  // std 表示除了mul,div等r_type，mdu表示mul,div等r_type
  wire [7:0] R_TYPE_EX,R_TYPE_STD_EX,R_TYPE_MDU_EX;
  wire [7:0] I_TYPE_EX;
  wire [7:0] S_TYPE_EX, B_TYPE_EX;
  wire [7:0] L_TYPE_EX, CSR_TYPE_EX;
  wire [7:0] FENCE_TYPE_EX;
  //下面这些指令其FUNC3和OP7完全一样，因此多判断一步,数字后缀表示其FUNC3是多少
  wire [7:0] R_TYPE_STD_EX_000;  //判断是SUB还是ADD
  wire [7:0] R_TYPE_STD_EX_101;  //判断是SRL还是SRA
  wire [7:0] I_TYPE_EX_101;  //判断是SRLI还算SRAI
  wire [7:0] E_TYPE_MRET_TYPE_EX_000;  //ECALL OR EBREAK OR MRET

  wire [3:0] E_TYPE_MRET_TYPE_OR_CSR_TYPE;
  assign E_TYPE_MRET_TYPE_OR_CSR_TYPE = (func3 == 3'b000)? `E_TYPE_MRET_TYPE : `CSR_TYPE;


  // 移除ID阶段的比较逻辑，分支判断移到EX阶段
  // EX阶段将使用id_ex_rs1_data和id_ex_rs2_data进行比较

  assign R_TYPE_STD_EX_000 = id_inst[30] ? `SUB_TYPE : `ADD_TYPE;
  assign R_TYPE_STD_EX_101 = id_inst[30] ? `SRA_TYPE : `SRL_TYPE;
  assign I_TYPE_EX_101 = id_inst[30] ? `SRA_TYPE : `SRL_TYPE;
  assign FENCE_TYPE_EX = (func3 == `FENCEI_INST) ? `FENCEI_TYPE : `FENCEE_TYPE;
  assign E_TYPE_MRET_TYPE_EX_000 = ((id_inst[21:20] == 2'b00) ? `ECALL_TYPE  :
                                  (id_inst[21:20] == 2'b01) ? `EBREAK_TYPE :
                                  (id_inst[21:20] == 2'b10) ? `MRET_TYPE   : 8'b0) ;

  assign id_reg_rs1_addr = id_inst[19:15];
  assign id_reg_rs2_addr = id_inst[24:20];
  assign id_ex_rd_addr   = id_inst[11:7] ;

  assign id_ex_is_csr = (inst_type == `CSR_TYPE);
  //传递pc值

  assign id_ex_csr_addr = id_inst[31:20];

  // 移除btype_jump1多路选择器，分支判断移到EX阶段
  // 对于B类型指令，传递立即数和PC值到EX阶段进行判断


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
  muxwithdefault #(10, 4, 1) i2 (
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
        `CSR_TYPE   ,1'b1 ,
        `L_TYPE     ,1'b1 ,
        `S_TYPE     ,1'b1
      }
  );
  muxwithdefault #(8, 4, 1) i3 (
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
        `AUIPC_TYPE ,1'b0 ,
        `S_TYPE     ,1'b1
      }
  );
  assign id_ex_rs1_data = reg_id_rs1_data;
  assign id_ex_rs2_data = reg_id_rs2_data;

  // 立即数选择：根据指令类型选择正确的立即数
  muxwithdefault #(10, 4, 32) i6 (
      id_ex_imm,
      inst_type,
      32'b0,
      {
        `R_TYPE     ,32'b0              ,  // R类型指令没有立即数
        `I_TYPE     ,sign_extended_immI ,  // I类型指令：符号扩展的immI
        `B_TYPE     ,sign_extended_immB ,  // B类型指令：符号扩展的immB（已左移1位）
        `JAL_TYPE   ,sign_extended_immJ ,  // JAL指令：符号扩展的immJ
        `JALR_TYPE  ,sign_extended_immI ,  // JALR指令：符号扩展的immI
        `LUI_TYPE   ,low_extended_immU  ,  // LUI指令：零扩展的immU
        `AUIPC_TYPE ,low_extended_immU  ,  // AUIPC指令：零扩展的immU
        `CSR_TYPE   ,32'b0              ,  // CSR指令没有立即数
        `L_TYPE     ,sign_extended_immI ,  // 加载指令：符号扩展的immI
        `S_TYPE     ,sign_extended_immS    // 存储指令：符号扩展的immS
      }
  );
 
  // for id_ex_alucex
  muxwithdefault #(8 ,3 ,8) R_TYPE_STD_FUNC3 (
      R_TYPE_STD_EX   ,
      func3           ,
      8'b0            ,
      {
        `ADD_SUB_INST ,R_TYPE_STD_EX_000 ,
        `SLL_INST     ,`SLL_TYPE         ,
        `SLT_INST     ,`SLT_TYPE         ,
        `SLTU_INST    ,`SLTU_TYPE        ,
        `XOR_INST     ,`XOR_TYPE         ,
        `SRL_SRA_INST ,R_TYPE_STD_EX_101 ,
        `OR_INST      ,`OR_TYPE          ,
        `AND_INST     ,`AND_TYPE

      }
  );

  muxwithdefault #(8 ,3 ,8) R_TYPE_MDU_FUNC3 (
      R_TYPE_MDU_EX  ,
      func3          ,
      8'b0           ,
      {
        `MUL_INST    ,`MUL_TYPE    ,
        `MULH_INST   ,`MULH_TYPE   ,
        `MULHSU_INST ,`MULHSU_TYPE ,
        `MULHU_INST  ,`MULHU_TYPE  ,
        `DIV_INST    ,`DIV_TYPE    ,
        `DIVU_INST   ,`DIVU_TYPE   ,
        `REM_INST    ,`REM_TYPE    ,
        `REMU_INST   ,`REMU_TYPE

      }
  );
  muxwithdefault #(8, 3, 8) I_TYPE_FUNC3 (
      I_TYPE_EX,
      func3,
      8'b0,
      {
        `ADDI_INST      ,`ADD_TYPE     ,
        `SLTI_INST      ,`SLT_TYPE     ,
        `SLTIU_INST     ,`SLTU_TYPE    ,
        `XORI_INST      ,`XOR_TYPE     ,
        `ORI_INST       ,`OR_TYPE      ,
        `ANDI_INST      ,`AND_TYPE     ,
        `SLLI_INST      ,`SLL_TYPE     ,
        `SRLI_SRAI_INST ,I_TYPE_EX_101

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

  assign R_TYPE_EX = id_inst[25]? R_TYPE_MDU_EX : R_TYPE_STD_EX;

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
        `FENCE_TYPE       ,FENCE_TYPE_EX
      }
  );


// for id_ex_rd_wen
  muxwithdefault #(9, 4, 1) i11 (
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
        `CSR_TYPE   ,1'b1 ,
        `L_TYPE     ,1'b1
      }
  );
  assign id_ex_rd_wen = (id_ex_rd_addr == 5'b0) ? 1'b0 : id_ex_rd_wen1;  //if rd = x0,not write

  // ========== Branch Prediction Metadata ==========
  // 检测是否是分支指令
  assign id_is_branch = (inst_type == `B_TYPE);

  // 传递IF阶段预测信息，仅在分支指令上生效
  assign id_branch_predicted = id_is_branch && id_if_predicted_taken;
  assign id_predicted_pc = id_if_predicted_pc;

  // ========== Multiplier Instruction Detection ==========
  // 检测是否是乘法指令 (MUL, MULH, MULHSU, MULHU)
  assign id_ex_is_mul_instruction = (id_ex_alucex == `MUL_TYPE) ||
                                     (id_ex_alucex == `MULH_TYPE) ||
                                     (id_ex_alucex == `MULHSU_TYPE) ||
                                     (id_ex_alucex == `MULHU_TYPE);

  // ========== Divider Instruction Detection ==========
  // 检测是否是除法指令 (DIV, DIVU, REM, REMU)
  assign id_ex_is_div_instruction = (id_ex_alucex == `DIV_TYPE) ||
                                     (id_ex_alucex == `DIVU_TYPE) ||
                                     (id_ex_alucex == `REM_TYPE) ||
                                     (id_ex_alucex == `REMU_TYPE);

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
