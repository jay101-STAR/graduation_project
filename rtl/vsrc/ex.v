`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
// `include "/home/jay/Desktop/graduation_project/vsrc/muxwithdefault.v"
module ex (
    input [ 3:0] id_ex_aluc,
    input [ 7:0] id_ex_alucex,
    input [ 4:0] id_ex_rd_addr,
    input        id_ex_rd_wen,
    input [31:0] id_ex_rs1_data,
    id_ex_rs2_data,
    input [ 4:0] id_ex_rs1_addr,
    input [31:0] id_ex_pc,

    input id_ex_branch_taken,
    input id_ex_csr_addr,
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
    output [11:0] ex_csr_csr_addr,
    output [31:0] ex_csr_rs1_data,
    output [31:0] ex_csr_trap_pc,     // 发生异常时所在地址
    output        ex_csr_trap_valid,
    output [31:0] ex_csr_trap_cause,

    output        ex_pc_pc_wen,
    output [31:0] ex_pc_pc_data

);
  wire [31:0] ex_reg_rd_data1;
  wire [31:0] result_add = id_ex_rs1_data + id_ex_rs2_data;
  wire [31:0] result_sll = id_ex_rs1_data << id_ex_rs2_data[4:0];
  wire [31:0] pc_plus_4 = id_ex_pc + 4;

  // trap 优先级最高，必须单独判断
  wire pc_redirect_trap = ex_csr_trap_valid;
  wire pc_redirect_mret = (id_ex_alucex == `MRET_TYPE) && !ex_csr_trap_valid;
  wire pc_redirect_jal = (id_ex_aluc == `JAL_TYPE) && !ex_csr_trap_valid;
  wire pc_redirect_jalr = (id_ex_aluc == `JALR_TYPE) && !ex_csr_trap_valid;
  wire pc_redirect_branch = (id_ex_aluc == `B_TYPE) && id_ex_branch_taken && !ex_csr_trap_valid;

  assign ex_pc_pc_wen = pc_redirect_trap | pc_redirect_mret |
                      pc_redirect_jal | pc_redirect_jalr | pc_redirect_branch;

  assign ex_pc_pc_data = pc_redirect_trap ? csr_ex_trap_vector : pc_redirect_mret ? csr_ex_mepc :
      // jal/jalr/branch 都是 result_add（jalr需要清除最低位）
      pc_redirect_jalr ? {result_add[31:1], 1'b0} : result_add;

  // muxwithdefault #(4, 4, 1) i0 (
  //     ex_pc_pc_wen,
  //     id_ex_aluc,
  //     1'b0,
  //     {
  //       `JAL_TYPE                    ,1'b1               ,
  //       `JALR_TYPE                   ,1'b1               ,
  //       `B_TYPE                      ,id_ex_branch_taken ,
  //       `E_TYPE_ZICSR_TYPE_MRET_TYPE ,(ex_csr_trap_valid == 1'b1 || id_ex_alucex == `MRET_TYPE)
  //     }
  // );
  // muxwithdefault #(4, 4, 32) i00 (
  //     ex_pc_pc_data,
  //     id_ex_aluc,
  //     pc_plus_4,
  //     {
  //       `JAL_TYPE                    ,result_add        ,
  //       `JALR_TYPE                   ,{result_add[31:1] ,1'b0} ,
  //       `B_TYPE                      ,result_add        ,
  //       `E_TYPE_ZICSR_TYPE_MRET_TYPE ,(id_ex_alucex == `MRET_TYPE) ? csr_ex_mepc : csr_ex_trap_vector
  //     }
  // );
  // verilog_format: off

  //得出rd_data的值
  muxwithdefault #(12, 8, 32) i1 (
      ex_reg_rd_data1,
      id_ex_alucex,
      32'b0,
      {
        `ADD_TYPE    ,result_add     ,
        `SLL_TYPE    ,result_sll     ,
        `AUIPCC_TYPE ,result_add     ,
        `LUII_TYPE   ,id_ex_rs1_data ,//immU
        `JALL_TYPE   ,pc_plus_4      ,
        `JALRR_TYPE  ,pc_plus_4      ,
        `CSRRC_TYPE  ,csr_ex_data    ,
        `CSRRS_TYPE  ,csr_ex_data    ,
        `CSRRW_TYPE  ,csr_ex_data    ,
        `CSRRCI_TYPE ,csr_ex_data    ,
        `CSRRSI_TYPE ,csr_ex_data    ,
        `CSRRWI_TYPE ,csr_ex_data

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
  muxwithdefault #(7, 4, 1) i3 (
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
        `CSR_TYPE   ,id_ex_rd_wen
      }
  );


  muxwithdefault #(7, 4, 5) i4 (
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
        `CSR_TYPE   ,id_ex_rd_addr
      }
  );
  // ex to csr
  //verilog_format: on

  assign ex_csr_alucex = id_ex_alucex;
  assign ex_csr_csr_addr = id_ex_csr_addr;
  assign ex_csr_rs1_data = id_ex_rs1_data;
  assign ex_csr_trap_valid = (id_ex_alucex == `ECALL_TYPE) ? 1'b1 :
                             (id_ex_alucex == `EBREAK_TYPE)? 1'b1 :
                             1'b0;
  assign ex_csr_trap_pc = id_ex_pc;
  assign ex_csr_ren = id_ex_is_csr &&
                      !(((id_ex_alucex == `CSRRW_TYPE) && id_ex_rd_addr == 0)
                      || ( (id_ex_alucex == `CSRRWI_TYPE) && id_ex_rd_addr == 0));

  //verilog_format: off

  muxwithdefault #(2, 8, 32) ex_csr_mcause1 (
      ex_csr_mcause,
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


endmodule
