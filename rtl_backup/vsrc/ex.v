`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
// `include "/home/jay/Desktop/graduation_project/rtl/vsrc/muxwithdefault.v"
module ex (
    input clk,
    input rst,

    input [ 3:0] id_ex_aluc,
    input [ 7:0] id_ex_alucex,
    input [ 4:0] id_ex_rd_addr,
    input        id_ex_rd_wen,
    input [31:0] id_ex_rs1_data,
    input [31:0] id_ex_rs2_data,
    input [ 4:0] id_ex_rs1_addr,
    input [31:0] id_ex_pc,
    input [31:0] id_ex_imm,       // 立即数，用于分支地址计算

    // 移除id_ex_branch_taken输入，在EX阶段进行分支判断
    // Branch prediction inputs from ID/EX register
    input        id_ex_branch_predicted,  // 预测是否跳转
    input [31:0] id_ex_predicted_pc,      // 预测的目标PC
    input        id_ex_is_branch,         // 是否是分支指令

    // Multiplier control signal
    input id_ex_is_mul_instruction,  // 是否是乘法指令

    // Divider control signal
    input id_ex_is_div_instruction,  // 是否是除法指令

    input id_ex_is_csr,

    input [31:0] csr_ex_data,
    input [31:0] csr_ex_trap_vector,  //异常时的跳转地址
    input [31:0] csr_ex_mepc,         //异常指令所在的地址

    output [31:0] ex_reg_rd_data,
    output [ 4:0] ex_reg_rd_addr,
    output        ex_reg_rd_wen,

    output        ex_csr_wen,
    output        ex_csr_ren,
    output [ 7:0] ex_csr_alucex,
    output [31:0] ex_csr_rs1_data,
    output [31:0] ex_csr_trap_pc,     // 发生异常时所在地址
    output        ex_csr_trap_valid,
    output [31:0] ex_csr_trap_cause,

    output        ex_pc_pc_wen,
    output [31:0] ex_pc_pc_data,

    output [31:0] ex_dataram_addr,
    output [31:0] ex_dataram_wdata,
    output        ex_dataram_wen,
    output        ex_dataram_ren,
    output [ 7:0] ex_dataram_alucex,

    // Multiplier status outputs
    output ex_mul_busy,
    output ex_mul_done,

    // Divider status outputs
    output ex_div_busy,
    output ex_div_done

);

  wire [31:0] id_ex_rs1_data_for_csr = id_ex_alucex[5] ? {27'b0, id_ex_rs1_addr} : id_ex_rs1_data;
  wire [31:0] op1, op2;
  //verilog_format:off
    muxwithdefault #(10, 4, 32) operand1 (
      op1,
      id_ex_aluc,
      32'b0,
      {
        `R_TYPE     ,id_ex_rs1_data    ,
        `I_TYPE     ,id_ex_rs1_data    ,
        `B_TYPE     ,id_ex_rs1_data    ,  // 分支指令：传递寄存器rs1的值
        `JALR_TYPE  ,id_ex_rs1_data    ,
        `JAL_TYPE   ,id_ex_imm ,
        `LUI_TYPE   ,id_ex_imm ,
        `AUIPC_TYPE ,id_ex_imm ,
        `CSR_TYPE   ,id_ex_rs1_data_for_csr ,
        `L_TYPE     ,id_ex_rs1_data   ,
        `S_TYPE     ,id_ex_rs1_data
      }
  );
    muxwithdefault #(10, 4, 32) operand2 (
      op2,
      id_ex_aluc,
      32'b0,
      {
        `R_TYPE     ,id_ex_rs2_data     ,
        `I_TYPE     ,id_ex_imm          ,
        `B_TYPE     ,id_ex_rs2_data     ,  // 分支指令：传递寄存器rs2的值
        `JALR_TYPE  ,id_ex_imm          ,
        `JAL_TYPE   ,id_ex_pc           ,
        `LUI_TYPE   ,32'b0              ,
        `AUIPC_TYPE ,id_ex_pc           ,
        `CSR_TYPE   ,32'b0              ,
        `L_TYPE     ,id_ex_rs2_data     ,
        `S_TYPE     ,id_ex_rs2_data
      }
  );

  wire [31:0] result_add = op1 + op2;
  wire [31:0] result_branch_target = id_ex_pc + id_ex_imm;  // 分支目标地址
  wire [31:0] result_sll = op1 << op2[4:0];
  wire [31:0] result_srl = op1 >> op2[4:0];
  wire [31:0] pc_plus_4 = id_ex_pc + 4;

  wire [31:0] result_sub = op1 - op2;
  wire [31:0] result_xor = op1 ^ op2;
  wire [31:0] result_or = op1 | op2;
  wire [31:0] result_and = op1 & op2;
  wire [31:0] result_sra = $signed(op1) >>> op2[4:0];
  wire [31:0] result_slt = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;
  wire [31:0] result_sltu = (op1 < op2) ? 32'd1 : 32'd0;

  wire [31:0] ex_reg_rd_data1;
  // ========== EX阶段分支判断逻辑 ==========
  // 在EX阶段进行分支条件判断（从ID阶段移动过来）
  wire rs1_signedlowerthan_rs2;
  wire rs1_signedbiggerthan_rs2;  // 包括大于等于
  wire rs1_equal_rs2;
  wire rs1_unequal_rs2;
  wire rs1_unsignedlowerthan_rs2;
  wire rs1_unsignedbigerthan_rs2;

  assign rs1_signedlowerthan_rs2   = ($signed(op1) < $signed(op2));
  assign rs1_signedbiggerthan_rs2  = (~rs1_signedlowerthan_rs2);
  assign rs1_unsignedlowerthan_rs2 = (op1 < op2);
  assign rs1_unsignedbigerthan_rs2 = (~rs1_unsignedlowerthan_rs2);
  assign rs1_equal_rs2             = (op1 == op2);
  assign rs1_unequal_rs2           = (~rs1_equal_rs2);

  // 分支跳转判断
  wire branch_taken;

  // verilog_format: off
  // 使用muxwithdefault模块进行分支判断（更稳定）
  muxwithdefault #(6, 8, 1) branch_judge (
      branch_taken,
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
  // verilog_format: on

  // 分支判断有效信号：只有在B_TYPE指令时才有效
  wire branch_taken_valid = (id_ex_aluc == `B_TYPE) ? branch_taken : 1'b0;

  // ========== Branch Prediction Verification ==========
  // 检测预测是否错误
  // 对于分支指令：比较预测结果与实际结果
  wire branch_misprediction = id_ex_is_branch && (id_ex_branch_predicted != branch_taken);

  // dataram interface
  assign ex_dataram_addr = ((id_ex_aluc == `S_TYPE)||(id_ex_aluc == `L_TYPE)) ? (op1 + id_ex_imm) : 32'b0;
  assign ex_dataram_wdata = op2;
  assign ex_dataram_wen = (id_ex_aluc == `S_TYPE);
  assign ex_dataram_ren = (id_ex_aluc == `L_TYPE);
  assign ex_dataram_alucex = id_ex_alucex;

  // trap 优先级最高，必须单独判断
  wire pc_redirect_trap = ex_csr_trap_valid;
  wire pc_redirect_mret = (id_ex_alucex == `MRET_TYPE) && !ex_csr_trap_valid;
  wire pc_redirect_jal = (id_ex_aluc == `JAL_TYPE) && !ex_csr_trap_valid;
  wire pc_redirect_jalr = (id_ex_aluc == `JALR_TYPE) && !ex_csr_trap_valid;

  // 分支重定向：只有在预测错误时才需要重定向PC
  // 如果预测正确，PC已经在ID阶段正确更新，不需要再次更新
  wire pc_redirect_branch = branch_misprediction && !ex_csr_trap_valid;

  assign ex_pc_pc_wen = pc_redirect_trap | pc_redirect_mret |
                      pc_redirect_jal | pc_redirect_jalr | pc_redirect_branch;

  assign ex_pc_pc_data = pc_redirect_trap ? csr_ex_trap_vector : pc_redirect_mret ? csr_ex_mepc :
      // jal/jalr使用result_add，branch使用result_branch_target（jalr需要清除最低位）
      pc_redirect_jalr ? {result_add[31:1], 1'b0} :
      // 分支预测错误时的PC恢复：
      // 如果实际taken，跳转到目标地址；如果实际not taken，跳转到PC+4
      pc_redirect_branch ? (branch_taken ? result_branch_target : pc_plus_4) : result_add;

  // verilog_format: off
  wire [31:0] mul_final_result;
  wire [31:0] div_final_result;
  //得出rd_data的值
  muxwithdefault #(28, 8, 32) i1 (
      ex_reg_rd_data1,
      id_ex_alucex,
      32'b0,
      {
        `ADD_TYPE    ,result_add       ,
        `SUB_TYPE    ,result_sub       ,
        `SLL_TYPE    ,result_sll       ,
        `SLT_TYPE    ,result_slt       ,
        `SLTU_TYPE   ,result_sltu      ,
        `XOR_TYPE    ,result_xor       ,
        `SRL_TYPE    ,result_srl       ,
        `SRA_TYPE    ,result_sra       ,
        `OR_TYPE     ,result_or        ,
        `AND_TYPE    ,result_and       ,
        `AUIPCC_TYPE ,result_add       ,
        `LUII_TYPE   ,op1              ,//immU
        `JALL_TYPE   ,pc_plus_4        ,
        `JALRR_TYPE  ,pc_plus_4        ,
        `CSRRC_TYPE  ,csr_ex_data      ,
        `CSRRS_TYPE  ,csr_ex_data      ,
        `CSRRW_TYPE  ,csr_ex_data      ,
        `CSRRCI_TYPE ,csr_ex_data      ,
        `CSRRSI_TYPE ,csr_ex_data      ,
        `CSRRWI_TYPE ,csr_ex_data      ,
        `MUL_TYPE    ,mul_final_result ,
        `MULH_TYPE   ,mul_final_result ,
        `MULHSU_TYPE ,mul_final_result ,
        `MULHU_TYPE  ,mul_final_result ,
        `DIV_TYPE    ,div_final_result ,
        `DIVU_TYPE   ,div_final_result ,
        `REM_TYPE    ,div_final_result ,
        `REMU_TYPE   ,div_final_result
      }
  );

  muxwithdefault #(7, 4, 32) i2 (
      ex_reg_rd_data,
      id_ex_aluc,
      32'b0,
      {
        `R_TYPE     ,ex_reg_rd_data1 ,
        `I_TYPE     ,ex_reg_rd_data1 ,
        `LUI_TYPE   ,ex_reg_rd_data1 ,
        `AUIPC_TYPE ,ex_reg_rd_data1 ,
        `JAL_TYPE   ,ex_reg_rd_data1 ,
        `JALR_TYPE  ,ex_reg_rd_data1 ,
        `CSR_TYPE   ,ex_reg_rd_data1
      }
  );

  //将wen,addr的值传递给regfile
  muxwithdefault #(8, 4, 1) i3 (
      ex_reg_rd_wen,
      id_ex_aluc,
      1'b0,
      {
        `R_TYPE     ,id_ex_rd_wen ,
        `I_TYPE     ,id_ex_rd_wen ,
        `JAL_TYPE   ,id_ex_rd_wen ,
        `JALR_TYPE  ,id_ex_rd_wen ,
        `LUI_TYPE   ,id_ex_rd_wen ,
        `AUIPC_TYPE ,id_ex_rd_wen ,
        `CSR_TYPE   ,id_ex_rd_wen ,
        `L_TYPE     ,id_ex_rd_wen
      }
  );


  muxwithdefault #(8, 4, 5) i4 (
      ex_reg_rd_addr,
      id_ex_aluc,
      5'b0,
      {
        `R_TYPE     ,id_ex_rd_addr ,
        `I_TYPE     ,id_ex_rd_addr ,
        `JAL_TYPE   ,id_ex_rd_addr ,
        `JALR_TYPE  ,id_ex_rd_addr ,
        `LUI_TYPE   ,id_ex_rd_addr ,
        `AUIPC_TYPE ,id_ex_rd_addr ,
        `CSR_TYPE   ,id_ex_rd_addr ,
        `L_TYPE     ,id_ex_rd_addr
      }
  );
  // ex to csr
  //verilog_format: on

  assign ex_csr_alucex = id_ex_alucex;
  assign ex_csr_rs1_data = op1;
  assign ex_csr_trap_valid = (id_ex_alucex == `ECALL_TYPE) ? 1'b1 :
                             (id_ex_alucex == `EBREAK_TYPE)? 1'b1 :
                             1'b0;
  assign ex_csr_trap_pc = id_ex_pc;
  assign ex_csr_ren = id_ex_is_csr &&
                      !(((id_ex_alucex == `CSRRW_TYPE) && id_ex_rd_addr == 0)
                      || ( (id_ex_alucex == `CSRRWI_TYPE) && id_ex_rd_addr == 0));

  //verilog_format: off

  muxwithdefault #(2, 8, 32) ex_csr_mcause1 (
      ex_csr_trap_cause,
      id_ex_alucex,
      32'b0,
      {`EBREAK_TYPE, 32'd3, `ECALL_TYPE, 32'd11}
  );


  muxwithdefault #(6, 8, 1) ex_csr_wen1 (
      ex_csr_wen,
      id_ex_alucex,
      1'b0,
      {
        `CSRRC_TYPE, (id_ex_rs1_addr != 5'b0),
        `CSRRS_TYPE, (id_ex_rs1_addr != 5'b0),
        `CSRRW_TYPE, 1'b1,

        // immediate versions
        `CSRRCI_TYPE, (id_ex_rs1_addr != 5'b0),  // uimm != 0
        `CSRRSI_TYPE, (id_ex_rs1_addr != 5'b0),
        `CSRRWI_TYPE, 1'b1
      }
  );


  // ========== 3-Cycle Multiplier Integration ==========
  // Multiplier control signals
  wire mul_start;
  wire mul_done;
  wire mul_busy;
  wire [63:0] mul_result;
  wire mul_a_sign, mul_b_sign;

  // Determine sign control based on instruction type
  assign mul_a_sign = (id_ex_alucex == `MUL_TYPE) ? 1'b1 :      // MUL: signed x signed
                      (id_ex_alucex == `MULH_TYPE) ? 1'b1 :     // MULH: signed x signed
                      (id_ex_alucex == `MULHSU_TYPE) ? 1'b1 :   // MULHSU: signed x unsigned
                      1'b0;                                      // MULHU: unsigned x unsigned

  assign mul_b_sign = (id_ex_alucex == `MUL_TYPE) ? 1'b1 :      // MUL: signed x signed
                      (id_ex_alucex == `MULH_TYPE) ? 1'b1 :     // MULH: signed x signed
                      (id_ex_alucex == `MULHSU_TYPE) ? 1'b0 :   // MULHSU: signed x unsigned
                      1'b0;                                      // MULHU: unsigned x unsigned

  // Start multiplier when a MUL instruction enters EX stage and multiplier is not busy
  assign mul_start = id_ex_is_mul_instruction && !mul_busy;

  // Instantiate 3-cycle multiplier
  mul_3cycle u_mul_3cycle (
      .clk        (clk),
      .rst_n      (~rst),
      .mul_a_i    (id_ex_rs1_data),
      .mul_b_i    (id_ex_rs2_data),
      .mul_a_sign (mul_a_sign),
      .mul_b_sign (mul_b_sign),
      .mul_start  (mul_start),
      .mul_result (mul_result),
      .mul_done   (mul_done),
      .mul_busy   (mul_busy)
  );

  // Select result based on instruction type
  assign mul_final_result = (id_ex_alucex == `MUL_TYPE) ? mul_result[31:0]:mul_result[63:32];// MULH/MULHSU/MULHU: upper 32 bits

  // Output multiplier status signals
  assign ex_mul_busy = mul_busy;
  assign ex_mul_done = mul_done;


  // ========== 32-Cycle Divider Integration ==========
  // Divider control signals
  wire div_start;
  wire div_done;
  wire div_busy;
  wire [31:0] div_result_q;  // Quotient
  wire [31:0] div_result_r;  // Remainder
  wire div_sign;

  // Determine sign control based on instruction type
  // DIV and REM are signed operations, DIVU and REMU are unsigned
  assign div_sign = (id_ex_alucex == `DIV_TYPE) || (id_ex_alucex == `REM_TYPE);

  // Start divider when a DIV instruction enters EX stage and divider is not busy
  assign div_start = id_ex_is_div_instruction && !div_busy;

  // Instantiate 32-cycle divider
  div u_div (
      .clk        (clk),
      .rst        (rst),
      .div_sign   (div_sign),
      .div_start  (div_start),
      .dividend   (id_ex_rs1_data),
      .divisor    (id_ex_rs2_data),
      .div_result_q (div_result_q),
      .div_result_r (div_result_r),
      .div_done   (div_done),
      .div_busy   (div_busy)
  );

  // Select result based on instruction type
  // DIV/DIVU return quotient, REM/REMU return remainder
  assign div_final_result = ((id_ex_alucex == `DIV_TYPE) || (id_ex_alucex == `DIVU_TYPE)) ?
                            div_result_q : div_result_r;

  // Output divider status signals
  assign ex_div_busy = div_busy;
  assign ex_div_done = div_done;


endmodule
