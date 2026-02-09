// 5-Stage Pipeline RISC-V CPU with Data Forwarding
// Stages: IF -> ID -> EX -> MEM -> WB
`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
module openmips (
    input clk,
    input rst,

    input  [31:0] instrom_openmips_data,
    output [31:0] openmips_instrom_addr,
    output        openmips_instrom_ren,
    output [31:0] tohost_value_register,
    output [31:0] tohost_value_dataram
);

  // ========== Pipeline Control Signals ==========
  wire stall_if_id, stall_id_ex, stall_ex_dataram, stall_dataram_wb;
  wire flush_if_id, flush_id_ex, flush_ex_dataram, flush_dataram_wb;

  // ========== IF Stage Wires ==========
  wire [31:0] pc_if_pc;
  wire [31:0] if_instruction;

  // ========== IF/ID Pipeline Register Wires ==========
  wire [31:0] if_id_instruction;

  // ========== ID Stage Wires ==========
  // ID to register file
  wire id_reg_rs1_ren, id_reg_rs2_ren;
  wire [4:0] id_reg_rs1_addr, id_reg_rs2_addr;
  wire [31:0] reg_id_rs1_data, reg_id_rs2_data;

  // Forwarded data (after forwarding logic)
  wire [31:0] forwarded_rs1_data, forwarded_rs2_data;

  // ID stage outputs
  wire [31:0] id_rs1_data, id_rs2_data;
  wire id_rd_wen;
  wire [4:0] id_rd_addr;
  wire [3:0] id_aluc;
  wire [7:0] id_alucex;
  wire [31:0] id_pc;
  wire [11:0] id_csr_addr;
  wire id_is_csr;
  // 移除id_branch_taken，分支判断移到EX阶段

  // Branch prediction signals from ID
  wire id_branch_predicted;  // 预测是否跳转
  wire [31:0] id_predicted_pc;  // 预测的目标PC
  wire id_is_branch;  // 是否是分支指令

  // Multiplier control signal from ID
  wire id_is_mul_instruction;  // 是否是乘法指令

  // Divider control signal from ID
  wire id_is_div_instruction;  // 是否是除法指令

  // ========== ID/EX Pipeline Register Wires ==========
  wire [31:0] id_ex_pc;
  wire [31:0] ex_rs1_data, ex_rs2_data;
  wire [4:0] ex_rs1_addr, ex_rs2_addr;
  wire [ 4:0] ex_rd_addr;
  wire [31:0] id_imm;  // 立即数从ID阶段输出
  wire [31:0] ex_imm;  // 立即数传递到EX阶段
  wire [ 3:0] ex_aluc;
  wire [ 7:0] ex_alucex;
  wire        ex_rd_wen;
  wire        ex_is_csr;
  wire [11:0] csr_addr;
  // 移除id_ex_branch_taken，分支判断在EX阶段进行

  // Branch prediction signals from ID/EX register
  wire        ex_branch_predicted;  // 预测是否跳转
  wire [31:0] ex_predicted_pc;  // 预测的目标PC
  wire        ex_is_branch;  // 是否是分支指令

  // Multiplier control signal from ID/EX register
  wire        ex_is_mul_instruction;  // 是否是乘法指令

  // Divider control signal from ID/EX register
  wire        ex_is_div_instruction;  // 是否是除法指令

  // ========== EX Stage Wires ==========
  // EX to CSR
  wire ex_csr_wen, ex_csr_ren;
  wire [7:0] ex_csr_alucex;
  wire [31:0] ex_csr_rs1_data;
  wire ex_csr_trap_valid;
  wire [31:0] ex_csr_trap_pc, ex_csr_trap_cause;

  // CSR to EX
  wire [31:0] csr_ex_data;
  wire [31:0] csr_ex_trap_vector, csr_ex_mepc;

  // EX to PC
  wire ex_pc_pc_wen;
  wire [31:0] ex_pc_pc_data;

  // EX stage outputs
  wire [31:0] ex_reg_rd_data;
  wire [4:0] ex_reg_rd_addr;
  wire ex_reg_rd_wen;
  wire [31:0] ex_dataram_addr, ex_dataram_wdata;
  wire ex_dataram_wen, ex_dataram_ren;
  wire dataram_ren, dataram_wen;
  wire [7:0] dataram_alucex;
  wire [31:0] dataram_addr, dataram_wdata;
  wire [ 7:0] ex_dataram_alucex;

  // Multiplier status signals from EX
  wire ex_mul_busy;
  wire ex_mul_done;

  // Divider status signals from EX
  wire ex_div_busy;
  wire ex_div_done;

  // ========== EX/MEM Pipeline Register Wires ==========
  wire [31:0] ex_dataram_alu_result;
  wire [4:0] ex_dataram_rd_addr;
  wire [3:0] ex_dataram_aluc;
  wire ex_dataram_rd_wen;

  // ========== MEM Stage Wires ==========
  wire [31:0] dataram_rdata;

  // ========== MEM/WB Pipeline Register Wires ==========
  wire [31:0] dataram_wb_alu_result;
  wire [31:0] wb_dataramrdata;
  wire [4:0] dataram_wb_rd_addr;
  wire [3:0] dataram_wb_aluc;
  wire dataram_wb_rd_wen;

  // ========== WB Stage Wires ==========
  wire [31:0] wb_reg_rd_data;
  wire [4:0] wb_reg_rd_addr;
  wire wb_reg_rd_wen;

  // ========== Hazard Detection and Control ==========
  // Load-use hazard detection
  // verilog_format: off
  wire load_use_hazard = (ex_aluc == `L_TYPE) &&  // L_TYPE
                         (ex_rd_wen == 1'b1)&&
                         (ex_rd_addr != 0) &&
                         ((ex_rd_addr == id_reg_rs1_addr && id_reg_rs1_ren) ||
                          (ex_rd_addr == id_reg_rs2_addr && id_reg_rs2_ren));

  // Multiplier hazard detection
  // When a MUL instruction is in EX stage, stall the pipeline immediately
  // Keep stalling until multiplier completes (mul_done)
  // Note: We stall as soon as MUL enters EX, not waiting for mul_busy
  wire mul_hazard = ex_is_mul_instruction && !ex_mul_done;

  // Divider hazard detection
  // When a DIV instruction is in EX stage, stall the pipeline immediately
  // Keep stalling until divider completes (div_done)
  // Note: Divider takes 32 cycles, much longer than multiplier (3 cycles)
  wire div_hazard = ex_is_div_instruction && !ex_div_done;

  // verilog_format: on
  // Branch/jump flush: 只有在预测错误或非分支跳转时才flush
  // ex_pc_pc_wen在预测错误时为1，此时需要flush流水线
  wire branch_flush = ex_pc_pc_wen;

  // ID阶段预测taken时，需要flush IF/ID寄存器（丢弃已取的PC+4指令）
  wire prediction_flush = id_branch_predicted;

  // Control signals
  assign stall_if_id = load_use_hazard || mul_hazard || div_hazard;
  assign stall_id_ex = mul_hazard || div_hazard;
  assign stall_ex_dataram = mul_hazard || div_hazard;  // Also stall EX/MEM register during multiplication/division
  assign stall_dataram_wb = 1'b0;

  // flush_if_id: 预测taken时flush（丢弃PC+4指令）或预测错误时flush
  assign flush_if_id = prediction_flush || branch_flush;
  assign flush_id_ex = branch_flush || load_use_hazard;
  assign flush_ex_dataram = 1'b0;
  assign flush_dataram_wb = 1'b0;

  // ========== IF Stage: PC Module ==========
  assign if_instruction = instrom_openmips_data;

  pc pc0 (
      .clk          (clk),
      .rst          (rst),
      .stall        (load_use_hazard || mul_hazard || div_hazard),
      .ren          (openmips_instrom_ren),
      .ex_pc_pc_wen (ex_pc_pc_wen),
      .ex_pc_pc_data(ex_pc_pc_data),
      // Branch prediction from ID stage
      .id_pc_wen    (id_branch_predicted),
      .id_pc_data   (id_predicted_pc),
      .next_pc      (openmips_instrom_addr),
      .pc_id_pc     (pc_if_pc)
  );

  // ========== IF/ID Pipeline Register ==========
  if_id_reg if_id_reg0 (
      .clk           (clk),
      .rst           (rst),
      .stall         (stall_if_id),
      .flush         (flush_if_id),
      .if_pc         (pc_if_pc),
      .if_instruction(if_instruction),
      .id_pc         (id_pc),
      .id_instruction(if_id_instruction)
  );

  // ========== ID Stage: Instruction Decode ==========
  id id0 (
      .id_inst                 (if_id_instruction),
      .pc_id_pc                (id_pc),
      .reg_id_rs1_data         (reg_id_rs1_data),        // Use forwarded data
      .reg_id_rs2_data         (reg_id_rs2_data),        // Use forwarded data
      .id_reg_rs1_ren          (id_reg_rs1_ren),
      .id_reg_rs2_ren          (id_reg_rs2_ren),
      .id_reg_rs1_addr         (id_reg_rs1_addr),
      .id_reg_rs2_addr         (id_reg_rs2_addr),
      .id_ex_rs1_data          (id_rs1_data),
      .id_ex_rs2_data          (id_rs2_data),
      .id_ex_rd_wen            (id_rd_wen),
      .id_ex_rd_addr           (id_rd_addr),
      .id_ex_aluc              (id_aluc),
      .id_ex_alucex            (id_alucex),
      .id_ex_imm               (id_imm),                 // 立即数输出
      .id_ex_csr_addr          (id_csr_addr),
      .id_ex_is_csr            (id_is_csr),
      // 移除.id_ex_branch_taken，分支判断移到EX阶段
      // Branch prediction outputs
      .id_branch_predicted     (id_branch_predicted),
      .id_predicted_pc         (id_predicted_pc),
      .id_is_branch            (id_is_branch),
      // Multiplier control output
      .id_ex_is_mul_instruction(id_is_mul_instruction),
      // Divider control output
      .id_ex_is_div_instruction(id_is_div_instruction)
  );

  // ========== ID/EX Pipeline Register ==========
  id_ex_reg id_ex_reg0 (
      .clk                  (clk),
      .rst                  (rst),
      .stall                (stall_id_ex),
      .flush                (flush_id_ex),
      .id_pc                (id_pc),
      .id_rs1_data          (id_rs1_data),
      .id_rs2_data          (id_rs2_data),
      .id_rs1_addr          (id_reg_rs1_addr),
      .id_rs2_addr          (id_reg_rs2_addr),
      .id_rd_addr           (id_rd_addr),
      .id_imm               (id_imm),                 // 立即数
      .id_aluc              (id_aluc),
      .id_alucex            (id_alucex),
      .id_rd_wen            (id_rd_wen),
      .id_is_csr            (id_is_csr),
      .id_csr_addr          (id_csr_addr),
      // 移除.id_branch_taken，分支判断移到EX阶段
      // Branch prediction inputs
      .id_branch_predicted  (id_branch_predicted),
      .id_predicted_pc      (id_predicted_pc),
      .id_is_branch         (id_is_branch),
      // Multiplier control input
      .id_is_mul_instruction(id_is_mul_instruction),
      // Divider control input
      .id_is_div_instruction(id_is_div_instruction),
      .ex_pc                (id_ex_pc),
      .ex_rs1_data          (ex_rs1_data),
      .ex_rs2_data          (ex_rs2_data),
      .ex_rs1_addr          (ex_rs1_addr),
      .ex_rs2_addr          (ex_rs2_addr),
      .ex_rd_addr           (ex_rd_addr),
      .ex_imm               (ex_imm),                 // 立即数传递到EX阶段
      .ex_aluc              (ex_aluc),
      .ex_alucex            (ex_alucex),
      .ex_rd_wen            (ex_rd_wen),
      .ex_is_csr            (ex_is_csr),
      .ex_csr_addr          (csr_addr),
      // 移除.ex_branch_taken，分支判断在EX阶段进行
      // Branch prediction outputs
      .ex_branch_predicted  (ex_branch_predicted),
      .ex_predicted_pc      (ex_predicted_pc),
      .ex_is_branch         (ex_is_branch),
      // Multiplier control output
      .ex_is_mul_instruction(ex_is_mul_instruction),
      // Divider control output
      .ex_is_div_instruction(ex_is_div_instruction)
  );
  //forward from dataram stage
  wire forward_dataram2ex_rs1 = (ex_dataram_rd_wen && (ex_dataram_rd_addr != 0) &&
                            (ex_dataram_rd_addr == ex_rs1_addr));
  wire forward_dataram2ex_rs2 = (ex_dataram_rd_wen && (ex_dataram_rd_addr != 0) &&
                            (ex_dataram_rd_addr == ex_rs2_addr));

  //forward from WB stage
  wire forward_wb2ex_rs1  = (wb_reg_rd_wen && (wb_reg_rd_addr != 0) &&
                             (wb_reg_rd_addr == ex_rs1_addr) &&
                             !forward_dataram2ex_rs1);
  wire forward_wb2ex_rs2  = (wb_reg_rd_wen && (wb_reg_rd_addr != 0) &&
                             (wb_reg_rd_addr == ex_rs2_addr) &&
                             !forward_dataram2ex_rs2);

  wire [31:0] ex_forwarded_rs1_data = forward_dataram2ex_rs1 ? ex_dataram_alu_result :
                                      forward_wb2ex_rs1 ? wb_reg_rd_data :
                                      ex_rs1_data;
  wire [31:0] ex_forwarded_rs2_data = forward_dataram2ex_rs2 ? ex_dataram_alu_result :
                                      forward_wb2ex_rs2 ? wb_reg_rd_data :
                                      ex_rs2_data;
  // ========== EX Stage: Execute ==========
  ex ex0 (
      .clk                     (clk),
      .rst                     (rst),
      .id_ex_aluc              (ex_aluc),
      .id_ex_alucex            (ex_alucex),
      .id_ex_rd_addr           (ex_rd_addr),
      .id_ex_rd_wen            (ex_rd_wen),
      .id_ex_rs1_data          (ex_forwarded_rs1_data),
      .id_ex_rs2_data          (ex_forwarded_rs2_data),
      .id_ex_rs1_addr          (ex_rs1_addr),
      .id_ex_pc                (id_ex_pc),
      .id_ex_imm               (ex_imm),                 // 立即数
      // 移除.id_ex_branch_taken，分支判断在EX模块内部进行
      // Branch prediction inputs
      .id_ex_branch_predicted  (ex_branch_predicted),
      .id_ex_predicted_pc      (ex_predicted_pc),
      .id_ex_is_branch         (ex_is_branch),
      .id_ex_is_mul_instruction(ex_is_mul_instruction),
      .id_ex_is_div_instruction(ex_is_div_instruction),
      .id_ex_is_csr            (ex_is_csr),
      .csr_ex_data             (csr_ex_data),
      .csr_ex_trap_vector      (csr_ex_trap_vector),
      .csr_ex_mepc             (csr_ex_mepc),
      .ex_reg_rd_wen           (ex_reg_rd_wen),
      .ex_reg_rd_data          (ex_reg_rd_data),
      .ex_reg_rd_addr          (ex_reg_rd_addr),
      .ex_pc_pc_wen            (ex_pc_pc_wen),
      .ex_pc_pc_data           (ex_pc_pc_data),
      .ex_csr_wen              (ex_csr_wen),
      .ex_csr_ren              (ex_csr_ren),
      .ex_csr_alucex           (ex_csr_alucex),
      .ex_csr_rs1_data         (ex_csr_rs1_data),
      .ex_csr_trap_pc          (ex_csr_trap_pc),
      .ex_csr_trap_valid       (ex_csr_trap_valid),
      .ex_csr_trap_cause       (ex_csr_trap_cause),
      .ex_dataram_addr         (ex_dataram_addr),
      .ex_dataram_wdata        (ex_dataram_wdata),
      .ex_dataram_wen          (ex_dataram_wen),
      .ex_dataram_ren          (ex_dataram_ren),
      .ex_dataram_alucex       (ex_dataram_alucex),
      .ex_mul_busy             (ex_mul_busy),
      .ex_mul_done             (ex_mul_done),
      .ex_div_busy             (ex_div_busy),
      .ex_div_done             (ex_div_done)
  );

  // ========== EX/MEM Pipeline Register ==========
  ex_dataram_reg ex_dataram_reg0 (
      .clk               (clk),
      .rst               (rst),
      .flush             (flush_ex_dataram),
      .stall             (stall_ex_dataram),
      .ex_alu_result     (ex_reg_rd_data),
      .ex_dataram_addr   (ex_dataram_addr),
      .ex_dataram_wdata  (ex_dataram_wdata),
      .ex_rd_addr        (ex_reg_rd_addr),
      .ex_aluc           (ex_aluc),
      .ex_alucex         (ex_dataram_alucex),
      .ex_rd_wen         (ex_reg_rd_wen),
      .ex_dataram_wen    (ex_dataram_wen),
      .ex_dataram_ren    (ex_dataram_ren),
      .dataram_alu_result(ex_dataram_alu_result),
      .dataram_addr      (dataram_addr),
      .dataram_wdata     (dataram_wdata),
      .dataram_rd_addr   (ex_dataram_rd_addr),
      .dataram_aluc      (ex_dataram_aluc),
      .dataram_alucex    (dataram_alucex),
      .dataram_rd_wen    (ex_dataram_rd_wen),
      .dataram_wen       (dataram_wen),
      .dataram_ren       (dataram_ren)
  );

  // ========== MEM Stage: Data Memory ==========
  dataram_banked dataram0 (
      .clk                 (clk),
      .rst                 (rst),
      .stall               (stall_ex_dataram),
      .ex_dataram_addr     (dataram_addr),
      .ex_dataram_wdata    (dataram_wdata),
      .ex_dataram_wen      (dataram_wen),
      .ex_dataram_ren      (dataram_ren),
      .ex_dataram_alucex   (dataram_alucex),
      .dataram_wb_rdata    (dataram_rdata),
      .tohost_value_dataram(tohost_value_dataram)
  );

  // ========== MEM/WB Pipeline Register ==========
  dataram_wb_reg dataram_wb_reg0 (
      .clk               (clk),
      .rst               (rst),
      .stall             (stall_dataram_wb),
      .flush             (flush_dataram_wb),
      .dataram_alu_result(ex_dataram_alu_result),
      .dataram_rd_addr   (ex_dataram_rd_addr),
      .dataram_aluc      (ex_dataram_aluc),
      .dataram_rd_wen    (ex_dataram_rd_wen),
      .wb_alu_result     (dataram_wb_alu_result),
      .wb_rd_addr        (dataram_wb_rd_addr),
      .wb_aluc           (dataram_wb_aluc),
      .wb_rd_wen         (dataram_wb_rd_wen)
  );

  // ========== WB Stage: Write Back ==========
  wb wb0 (
      .ex_wb_alu_result(dataram_wb_alu_result),
      .ex_wb_rd_addr   (dataram_wb_rd_addr),
      .ex_wb_rd_wen    (dataram_wb_rd_wen),
      .ex_wb_aluc      (dataram_wb_aluc),
      .dataram_wb_rdata(dataram_rdata),
      .wb_reg_rd_data  (wb_reg_rd_data),
      .wb_reg_rd_addr  (wb_reg_rd_addr),
      .wb_reg_rd_wen   (wb_reg_rd_wen)
  );

  // ========== Register File ==========
  chj_registerfile registerfile0 (
      .clk                  (clk),
      .rst                  (rst),
      .wdata                (wb_reg_rd_data),
      .waddr                (wb_reg_rd_addr),
      .wen                  (wb_reg_rd_wen),
      .rs1_ren              (id_reg_rs1_ren),
      .rs1_raddr            (id_reg_rs1_addr),
      .rs2_ren              (id_reg_rs2_ren),
      .rs2_raddr            (id_reg_rs2_addr),
      .rs1_rdata            (reg_id_rs1_data),
      .rs2_rdata            (reg_id_rs2_data),
      .tohost_value_register(tohost_value_register)
  );

  // ========== CSR Module ==========
  csr csr0 (
      .clk               (clk),
      .rst               (rst),
      .ex_csr_wen        (ex_csr_wen),
      .ex_csr_ren        (ex_csr_ren),
      .ex_csr_alucex     (ex_csr_alucex),
      .ex_csr_addr       (csr_addr),
      .ex_csr_rs1_data   (ex_csr_rs1_data),
      .ex_csr_trap_valid (ex_csr_trap_valid),
      .ex_csr_trap_pc    (ex_csr_trap_pc),
      .ex_csr_trap_cause (ex_csr_trap_cause),
      .csr_ex_data       (csr_ex_data),
      .csr_ex_trap_vector(csr_ex_trap_vector),
      .csr_ex_mepc       (csr_ex_mepc)
  );

endmodule
