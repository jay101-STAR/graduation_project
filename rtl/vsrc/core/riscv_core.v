// 5-Stage Pipeline RISC-V CPU with Data Forwarding
// Stages: IF -> ID -> EX -> MEM -> WB
`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
module riscv_core #(
    parameter integer ICACHE_ENABLE = 1,
    parameter integer DCACHE_ENABLE = 0
) (
    input         clk,
    input         rst,

    // Native burst interface to the external bus master. Request lengths are
    // beats minus one; read data ends with LAST, writes complete on response.
    output        mem_rd_req_valid,
    input         mem_rd_req_ready,
    output [31:0] mem_rd_req_addr,
    output [ 7:0] mem_rd_req_len,
    input         mem_rd_rsp_valid,
    output        mem_rd_rsp_ready,
    input  [31:0] mem_rd_rsp_rdata,
    input         mem_rd_rsp_error,
    input         mem_rd_rsp_last,
    output        mem_wr_req_valid,
    input         mem_wr_req_ready,
    output [31:0] mem_wr_req_addr,
    output [ 7:0] mem_wr_req_len,
    output [31:0] mem_wr_req_wdata,
    output [ 3:0] mem_wr_req_wstrb,
    output        mem_wr_req_wlast,
    input         mem_wr_rsp_valid,
    output        mem_wr_rsp_ready,
    input         mem_wr_rsp_error,

    output [31:0] tohost_value_register,
    output reg [31:0] core_bp_branch_total,
    output reg [31:0] core_bp_mispredict_total,
    output reg [31:0] core_bp_target_miss_total
);

  // Core-local fetch/data handshakes and cache maintenance. These signals
  // connect the pipeline directly to the adapters and physical cache ports.
  wire [31:0] instrom_core_data;
  wire [31:0] instrom_core_pc;
  wire [31:0] core_instrom_addr;
  wire        core_instrom_ren;
  wire [31:0] core_dataram_addr;
  wire [31:0] core_dataram_wdata;
  wire        core_dataram_wen;
  wire        core_dataram_ren;
  wire [ 7:0] core_dataram_alucex;
  wire        core_dataram_stall;
  wire [31:0] dataram_core_rdata;
  wire        top_core_mem_stall;
  wire if_req_ready, if_rsp_valid, if_rsp_ready, if_rsp_error;
  wire [3:0] if_req_id, if_rsp_id;
  wire icache_invalidate;
  wire data_req_valid, data_req_ready, data_rsp_valid, data_rsp_ready, data_rsp_error;
  wire [3:0] data_req_id, data_rsp_id;
  wire backend_if_start, backend_data_start, backend_data_write;
  wire [31:0] backend_if_addr, backend_data_addr, backend_data_wdata;
  wire [ 7:0] backend_data_alucex;
  wire [31:0] backend_data_rdata;
  wire backend_data_busy, backend_data_error;
  wire [31:0] backend_data_fault_addr, data_rsp_fault_addr;

  // ========== Pipeline Control Signals ==========
  wire stall_if_id, stall_id_ex, stall_ex_dataram, stall_dataram_wb;
  wire flush_if_id, flush_id_ex, flush_ex_dataram, flush_dataram_wb;

  // ========== IF Stage Wires ==========
  wire [31:0] pc_if_pc;
  wire [31:0] if_instruction;
  reg  [31:0] if1_pc;
  reg         if1_valid;
  reg         if1_predicted_taken;
  reg  [31:0] if1_predicted_pc;
  reg  [ 9:0] if1_predicted_pht_index;

  reg  [31:0] if2_pc;
  reg  [31:0] if2_instruction;
  reg         if2_valid;
  reg         if2_fault;
  reg         if2_predicted_taken;
  reg  [31:0] if2_predicted_pc;
  reg  [ 9:0] if2_predicted_pht_index;
  reg         if_request_valid;
  reg         if_request_killed;
  reg  [31:0] if_offer_pc;
  reg         if_offer_killed;
  reg         if_offer_predicted_taken;
  reg  [31:0] if_offer_predicted_pc;
  reg  [9:0]  if_offer_predicted_pht_index;
  reg  [3:0]  if_next_id;
  reg  [3:0]  if_pending_id;
  wire        pc_fetch_enable;
  wire [31:0] pc_next_fetch;
  wire        if_req_fire = core_instrom_ren && if_req_ready;
  wire        if_rsp_fire = if_rsp_valid && if_rsp_ready;
  wire [31:0] if2_instruction_aligned;
  wire        if2_predicted_taken_aligned;
  wire [31:0] if2_predicted_pc_aligned;
  wire [ 9:0] if2_predicted_pht_index_aligned;

  // ========== IF/ID Pipeline Register Wires ==========
  wire [31:0] if_id_instruction;
  wire if_id_valid;
  wire if_id_fault;
  wire if_id_predicted_taken;
  wire [31:0] if_id_predicted_pc;
  wire [9:0] if_id_predicted_pht_index;

  // ========== ID Stage Wires ==========
  // ID to register file
  wire id_reg_rs1_ren, id_reg_rs2_ren;
  wire [4:0] id_reg_rs1_addr, id_reg_rs2_addr;
  wire [31:0] reg_id_rs1_data, reg_id_rs2_data;


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
  wire if_bp_predict_taken;  // IF阶段预测是否跳转
  wire [31:0] if_bp_predict_pc;  // IF阶段预测目标PC
  wire [9:0] if_bp_predict_pht_index;  // IF阶段gshare索引

  // Multiplier control signal from ID
  wire id_is_mul_instruction;  // 是否是乘法指令

  // Divider control signal from ID
  wire id_is_div_instruction;  // 是否是除法指令

  // ========== ID/EX Pipeline Register Wires ==========
  wire [31:0] id_ex_pc;
  wire [31:0] ex_rs1_data, ex_rs2_data;
  // Declared here so ex_control_target (branch/JALR 目标计算) can reference the
  // forwarded rs1 value before the forwarding muxes below; assigned later.
  wire [31:0] ex_forwarded_rs1_data;
  wire        ex_valid;
  wire        ex_fetch_fault;
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
  wire [9:0] ex_predicted_pht_index;  // 预测时的gshare索引
  wire        ex_is_branch;  // 是否是分支指令
  wire        ex_jal_resolved;

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
  wire        csr_ex_illegal;  // 非法指令（cause=2），来自 CSR/MRET 合法性检查

  // EX to PC
  wire ex_pc_pc_wen;
  wire [31:0] ex_pc_pc_data;
  wire ex_bp_update_wen;
  wire [31:0] ex_bp_update_pc;
  wire ex_bp_update_taken;
  wire [31:0] ex_bp_update_target;
  wire [9:0] ex_bp_update_pht_index;
  wire ex_bp_event_branch;
  wire ex_bp_event_mispredict;
  wire ex_bp_event_target_miss;

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
  wire [31:0] mem_instruction_pc;
  wire        ex_dataram_valid;
  wire [4:0] ex_dataram_rd_addr;
  wire [3:0] ex_dataram_aluc;
  wire ex_dataram_rd_wen;

  // ========== MEM Stage Wires ==========
  // dataram is external in top

  // ========== MEM/WB Pipeline Register Wires ==========
  wire [31:0] dataram_wb_alu_result;
  wire [31:0] dataram_wb_load_data;
  reg wb_consumed;
  wire wb_rd_wen_raw;
  reg data_request_sent;
  reg data_response_saved;
  reg [31:0] data_saved_rdata;
  reg data_saved_error;
  reg [31:0] data_saved_fault_addr;
  reg [3:0] data_next_id, data_pending_id;
  wire mem_access = ex_dataram_valid && (dataram_ren || dataram_wen);
  wire data_req_fire = data_req_valid && data_req_ready;
  wire data_rsp_fire = data_rsp_valid && data_rsp_ready;
  wire mem_result_valid = data_response_saved || data_rsp_fire;
  wire [31:0] mem_result_data = data_response_saved ? data_saved_rdata : dataram_core_rdata;
  wire mem_result_error = data_response_saved ? data_saved_error : data_rsp_error;
  wire [31:0] mem_fault_addr = data_response_saved ? data_saved_fault_addr : data_rsp_fault_addr;
  wire mem_wait = mem_access && !mem_result_valid;
  // Older MEM faults win over every younger EX operation, including a CSR,
  // redirect, or stalled MUL/DIV. Older WB entries still retire on this edge.
  wire mem_fault = mem_access && mem_result_valid && mem_result_error;
  wire mem_trap_fire = !rst && mem_fault;
  wire ex_fire = ex_valid && !stall_ex_dataram && !mem_fault;
  // Keep IALIGN=32 failures distinct from physical access faults. The fault
  // belongs to the control-flow instruction, not a later fetch of its target.
  wire [31:0] ex_control_target = (ex_aluc == `JALR_TYPE) ?
                                  ((ex_forwarded_rs1_data + ex_imm) & 32'hfffffffe) :
                                  id_ex_pc + ex_imm;
  wire ex_control_taken = ex_aluc == `JAL_TYPE || ex_aluc == `JALR_TYPE ||
                          (ex_aluc == `B_TYPE && ex_bp_update_taken);
  wire ex_target_misaligned = ex_control_taken && (ex_control_target[1:0] != 0);
  wire ex_instruction_trap = ex_fetch_fault || ex_target_misaligned || csr_ex_illegal || ex_csr_trap_valid;
  wire trap_fire = mem_trap_fire || (ex_fire && ex_instruction_trap);
  wire [31:0] trap_pc = mem_trap_fire ? mem_instruction_pc : id_ex_pc;
  // 优先级：较老 MEM 访问异常 > 取指异常 > 目标未对齐 > 非法指令 > ECALL/EBREAK。
  wire [31:0] trap_cause = mem_trap_fire ? (dataram_wen ? 32'd7 : 32'd5) :
                          ex_fetch_fault ? 32'd1 : ex_target_misaligned ? 32'd0 :
                          csr_ex_illegal ? 32'd2 : ex_csr_trap_cause;
  wire [31:0] trap_tval = mem_trap_fire ? mem_fault_addr : ex_fetch_fault ? id_ex_pc :
                         ex_target_misaligned ? ex_control_target : 32'b0;
  wire        dataram_wb_valid;
  wire [4:0] dataram_wb_rd_addr;
  wire [3:0] dataram_wb_aluc;
  wire dataram_wb_rd_wen;

  // ========== WB Stage Wires ==========
  wire [31:0] wb_reg_rd_data;
  wire [4:0] wb_reg_rd_addr;
  wire wb_reg_rd_wen;
  wire retire_pulse;

  // ========== Hazard Detection and Control ==========
  // Load-use hazard detection
  // verilog_format: off
  wire load_use_hazard = ex_valid && (ex_aluc == `L_TYPE) &&  // L_TYPE
                         (ex_rd_wen == 1'b1)&&
                         (ex_rd_addr != 0) &&
                         ((ex_rd_addr == id_reg_rs1_addr && id_reg_rs1_ren) ||
                          (ex_rd_addr == id_reg_rs2_addr && id_reg_rs2_ren));

  // Multiplier hazard detection
  // When a MUL instruction is in EX stage, stall the pipeline immediately
  // Keep stalling until multiplier completes (mul_done)
  // Note: We stall as soon as MUL enters EX, not waiting for mul_busy
  wire mul_hazard = ex_valid && ex_is_mul_instruction && !ex_mul_done;

  // Divider hazard detection
  // When a DIV instruction is in EX stage, stall the pipeline immediately
  // Keep stalling until divider completes (div_done)
  // Note: Divider takes 32 cycles, much longer than multiplier (3 cycles)
  wire div_hazard = ex_valid && ex_is_div_instruction && !ex_div_done;

  // verilog_format: on
  // Branch/jump flush: 只有在预测错误或非分支跳转时才flush
  // ex_pc_pc_wen在预测错误时为1，此时需要flush流水线
  wire branch_flush = trap_fire || (ex_pc_pc_wen && ex_fire);

  // Resolve direct jumps when ID advances. An older EX redirect wins, and
  // flushing the front end must not discard the JAL entering ID/EX itself.
  wire [31:0] id_jal_target = id_pc + id_imm;
  wire id_jal_advance = !rst && if_id_valid && !if_id_fault && (id_aluc == `JAL_TYPE) &&
                        (id_jal_target[1:0] == 0) && !stall_if_id && !branch_flush;
  wire id_jal_prediction_ok = if_id_predicted_taken &&
                              (if_id_predicted_pc == id_jal_target);
  wire id_jal_redirect = id_jal_advance && !id_jal_prediction_ok;
  wire frontend_flush = branch_flush || id_jal_redirect;

  // Train once on an accepted EX instruction; a stalled JAL must not retrain.
  wire ex_is_jal = (ex_aluc == `JAL_TYPE);
  wire bp_update_valid = ex_fire && !ex_instruction_trap;
  wire bp_invalidate = bp_update_valid && (ex_alucex == `FENCEI_TYPE);
  // Older stores have completed before EX can advance. The cache boundary
  // drains old fetches, invalidates, then permits the redirected fetch stream.
  assign icache_invalidate = bp_invalidate;

  // Control signals
  assign stall_if_id = load_use_hazard || mul_hazard || div_hazard || mem_wait || top_core_mem_stall;
  assign stall_id_ex = mul_hazard || div_hazard || mem_wait || top_core_mem_stall;
  assign stall_ex_dataram = mul_hazard || div_hazard || mem_wait || top_core_mem_stall;  // Also stall EX/MEM register during multiplication/division
  assign stall_dataram_wb = stall_ex_dataram;

  assign flush_if_id = frontend_flush;
  assign flush_id_ex = branch_flush || (load_use_hazard && !stall_id_ex);
  assign flush_ex_dataram = mem_trap_fire;
  assign flush_dataram_wb = mem_trap_fire;

  assign core_dataram_addr = dataram_addr;
  assign core_dataram_wdata = dataram_wdata;
  assign core_dataram_wen = dataram_wen;
  assign core_dataram_ren = dataram_ren;
  assign core_dataram_alucex = dataram_alucex;
  assign core_dataram_stall = stall_ex_dataram;
  // A held WB entry commits once, but remains available for forwarding until
  // the pipeline advances. Load data is held in the same register as its rd.
  assign retire_pulse = dataram_wb_valid && !wb_consumed;
  assign wb_reg_rd_wen = wb_rd_wen_raw && retire_pulse;
  assign data_req_valid = !rst && mem_access && !data_request_sent;
  assign data_req_id = data_next_id;
  assign data_rsp_ready = !rst && data_request_sent && !data_response_saved &&
                          (data_rsp_id == data_pending_id);

  always @(posedge clk) begin
    if (rst) begin
      wb_consumed <= 1'b0;
      data_request_sent <= 1'b0;
      data_response_saved <= 1'b0;
      data_saved_rdata <= 32'b0;
      data_saved_error <= 1'b0;
      data_saved_fault_addr <= 32'b0;
      data_next_id <= 4'b0;
      data_pending_id <= 4'b0;
    end else begin
      if (!stall_dataram_wb) wb_consumed <= 1'b0;
      else if (retire_pulse) wb_consumed <= 1'b1;
      if (data_req_fire) begin
        data_request_sent <= 1'b1;
        data_pending_id <= data_next_id;
        data_next_id <= data_next_id + 1'b1;
      end
      if (data_rsp_fire) begin
        data_response_saved <= 1'b1;
        data_saved_rdata <= dataram_core_rdata;
        data_saved_error <= data_rsp_error;
        data_saved_fault_addr <= data_rsp_fault_addr;
      end
      if (mem_trap_fire || !stall_ex_dataram) begin
        data_request_sent <= 1'b0;
        data_response_saved <= 1'b0;
      end
    end
  end

  // Branch prediction statistics counters
  always @(posedge clk) begin
    if (rst) begin
      core_bp_branch_total <= 32'b0;
      core_bp_mispredict_total <= 32'b0;
      core_bp_target_miss_total <= 32'b0;
    end else begin
      if (bp_update_valid && ex_bp_event_branch) begin
        core_bp_branch_total <= core_bp_branch_total + 32'b1;
      end
      if (bp_update_valid && ex_bp_event_mispredict) begin
        core_bp_mispredict_total <= core_bp_mispredict_total + 32'b1;
      end
      if (bp_update_valid && ex_bp_event_target_miss) begin
        core_bp_target_miss_total <= core_bp_target_miss_total + 32'b1;
      end
    end
  end

  // ========== IF Stage: one request / one response ==============
  assign if_instruction = instrom_core_data;
  wire if_can_offer = pc_fetch_enable && !frontend_flush && !stall_if_id &&
                      (!if1_valid || if_rsp_fire);
  wire if_offered_killed = if_request_valid && if_offer_killed;
  wire if_offered_predicted_taken = if_request_valid ? if_offer_predicted_taken : if_bp_predict_taken;
  wire [31:0] if_offered_predicted_pc = if_request_valid ? if_offer_predicted_pc : if_bp_predict_pc;
  wire [9:0] if_offered_predicted_pht_index = if_request_valid ?
      if_offer_predicted_pht_index : if_bp_predict_pht_index;
  assign core_instrom_addr = if_request_valid ? if_offer_pc : pc_next_fetch;
  assign core_instrom_ren = !rst && (if_request_valid || if_can_offer);
  assign if_req_id = if_next_id;
  assign if_rsp_ready = !rst && if1_valid && (if_rsp_id == if_pending_id) &&
                        (if_request_killed || frontend_flush || !if2_valid || !stall_if_id);

  pc pc0 (
      .clk(clk), .rst(rst),
      .stall(!(if_req_fire && !if_offered_killed)),
      .ren(pc_fetch_enable),
      .ex_pc_pc_wen(frontend_flush),
      .ex_pc_pc_data(trap_fire ? csr_ex_trap_vector : branch_flush ? ex_pc_pc_data : id_jal_target),
      .id_pc_wen(if_offered_predicted_taken),
      .id_pc_data(if_offered_predicted_pc),
      .next_pc(pc_next_fetch),
      .pc_id_pc(pc_if_pc)
  );

  // An unblocked request goes straight to memory. Only a blocked offer needs
  // holding registers; accepted metadata belongs to the independent IF1 slot.
  // Pop the old response and push its replacement at the same edge. Redirects
  // kill both outstanding work and held offers without withdrawing VALID.
  always @(posedge clk) begin
    if (rst) begin
      if_request_valid <= 1'b0;
      if_request_killed <= 1'b0;
      if_offer_pc <= `PC_BASE_ADDR;
      if_offer_killed <= 1'b0;
      if_offer_predicted_taken <= 1'b0;
      if_offer_predicted_pc <= `PC_BASE_ADDR + 32'd4;
      if_offer_predicted_pht_index <= 10'b0;
      if_next_id <= 4'b0;
      if_pending_id <= 4'b0;
      if1_valid <= 1'b0;
      if1_pc <= `PC_BASE_ADDR;
      if1_predicted_taken <= 1'b0;
      if1_predicted_pc <= `PC_BASE_ADDR + 32'd4;
      if1_predicted_pht_index <= 10'b0;
      if2_valid <= 1'b0;
      if2_fault <= 1'b0;
      if2_pc <= `PC_BASE_ADDR;
      if2_instruction <= 32'h0000_0013;
      if2_predicted_taken <= 1'b0;
      if2_predicted_pc <= 32'b0;
      if2_predicted_pht_index <= 10'b0;
    end else begin
      if (!stall_if_id) if2_valid <= 1'b0;
      if (frontend_flush) begin
        if2_valid <= 1'b0;
        if (if1_valid) if_request_killed <= 1'b1;
        if (if_request_valid) if_offer_killed <= 1'b1;
      end
      if (if_rsp_fire) begin
        if1_valid <= 1'b0;
        if (!if_request_killed && !frontend_flush) begin
          if2_valid <= 1'b1;
          if2_pc <= if1_pc;
          // Carry the failure with a harmless decode payload. A wrong-path
          // fetch can still be killed by an older branch before reaching EX.
          if2_instruction <= if_rsp_error ? 32'h00000013 : if_instruction;
          if2_fault <= if_rsp_error;
          if2_predicted_taken <= !if_rsp_error && if1_predicted_taken;
          if2_predicted_pc <= if1_predicted_pc;
          if2_predicted_pht_index <= if1_predicted_pht_index;
        end
      end
      if (core_instrom_ren && !if_req_ready && !if_request_valid) begin
        if_request_valid <= 1'b1;
        if_offer_killed <= 1'b0;
        if_offer_pc <= pc_next_fetch;
        if_offer_predicted_taken <= if_bp_predict_taken;
        if_offer_predicted_pc <= if_bp_predict_pc;
        if_offer_predicted_pht_index <= if_bp_predict_pht_index;
      end
      if (if_req_fire) begin
        if_request_valid <= 1'b0;
        if_request_killed <= if_offered_killed || frontend_flush;
        if1_valid <= 1'b1;
        if1_pc <= core_instrom_addr;
        if1_predicted_taken <= if_offered_predicted_taken;
        if1_predicted_pc <= if_offered_predicted_pc;
        if1_predicted_pht_index <= if_offered_predicted_pht_index;
        if_pending_id <= if_next_id;
        if_next_id <= if_next_id + 1'b1;
      end
    end
  end

  // Only allow valid BRAM return beats into IF/ID.
  assign if2_instruction_aligned = if2_valid ? if2_instruction : 32'h0000_0013;
  assign if2_predicted_taken_aligned = if2_valid ? if2_predicted_taken : 1'b0;
  assign if2_predicted_pc_aligned = if2_valid ? if2_predicted_pc : 32'b0;
  assign if2_predicted_pht_index_aligned = if2_valid ? if2_predicted_pht_index : 10'b0;

  // ========== IF/ID Pipeline Register ==========
  if_id_reg if_id_reg0 (
      .clk               (clk),
      .rst               (rst),
      .stall             (stall_if_id),
      .flush             (flush_if_id),
      .if_pc             (if2_pc),
      .if_instruction    (if2_instruction_aligned),
      .if_valid          (if2_valid),
      .if_fault          (if2_fault),
      .if_predicted_taken(if2_predicted_taken_aligned),
      .if_predicted_pc   (if2_predicted_pc_aligned),
      .if_predicted_pht_index(if2_predicted_pht_index_aligned),
      .id_pc             (id_pc),
      .id_instruction    (if_id_instruction),
      .id_valid          (if_id_valid),
      .id_fault          (if_id_fault),
      .id_predicted_taken(if_id_predicted_taken),
      .id_predicted_pc   (if_id_predicted_pc),
      .id_predicted_pht_index(if_id_predicted_pht_index)
  );

  // ========== Branch Predictor (BHT Direction) ==========
  branch_predictor branch_predictor0 (
      .clk                (clk),
      .rst                (rst),
      .invalidate         (bp_invalidate),
      .if_bp_pc           (pc_next_fetch),
      .if_bp_predict_taken(if_bp_predict_taken),
      .if_bp_predict_pc   (if_bp_predict_pc),
      .if_bp_predict_pht_index(if_bp_predict_pht_index),
      .ex_bp_update_wen   (bp_update_valid && (ex_bp_update_wen || ex_is_jal)),
      .ex_bp_update_is_jal(ex_is_jal),
      .ex_bp_update_pc    (ex_bp_update_pc),
      .ex_bp_update_taken (ex_is_jal || ex_bp_update_taken),
      .ex_bp_update_target(ex_is_jal ? (id_ex_pc + ex_imm) : ex_bp_update_target),
      .ex_bp_update_pht_index(ex_bp_update_pht_index)
  );

  // ========== ID Stage: Instruction Decode ==========
  id id0 (
      .id_inst                 (if_id_instruction),
      .pc_id_pc                (id_pc),
      .id_if_predicted_taken   (if_id_predicted_taken),
      .id_if_predicted_pc      (if_id_predicted_pc),
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
      .id_valid             (if_id_valid),
      .id_fault             (if_id_fault),
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
      .id_predicted_pht_index(if_id_predicted_pht_index),
      .id_is_branch         (id_is_branch),
      .id_jal_resolved      (id_jal_advance),
      // Multiplier control input
      .id_is_mul_instruction(id_is_mul_instruction),
      // Divider control input
      .id_is_div_instruction(id_is_div_instruction),
      .ex_pc                (id_ex_pc),
      .ex_rs1_data          (ex_rs1_data),
      .ex_rs2_data          (ex_rs2_data),
      .ex_valid             (ex_valid),
      .ex_fault             (ex_fetch_fault),
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
      .ex_predicted_pht_index(ex_predicted_pht_index),
      .ex_is_branch         (ex_is_branch),
      .ex_jal_resolved      (ex_jal_resolved),
      // Multiplier control output
      .ex_is_mul_instruction(ex_is_mul_instruction),
      // Divider control output
      .ex_is_div_instruction(ex_is_div_instruction)
  );
  //forward from dataram stage
  wire forward_dataram2ex_rs1 = (ex_dataram_valid && !mem_fault && (!dataram_ren || mem_result_valid) && ex_dataram_rd_wen && (ex_dataram_rd_addr != 0) &&
                            (ex_dataram_rd_addr == ex_rs1_addr));
  wire forward_dataram2ex_rs2 = (ex_dataram_valid && !mem_fault && (!dataram_ren || mem_result_valid) && ex_dataram_rd_wen && (ex_dataram_rd_addr != 0) &&
                            (ex_dataram_rd_addr == ex_rs2_addr));

  //forward from WB stage
  wire forward_wb2ex_rs1  = (dataram_wb_valid && wb_rd_wen_raw && (wb_reg_rd_addr != 0) &&
                             (wb_reg_rd_addr == ex_rs1_addr) &&
                             !forward_dataram2ex_rs1);
  wire forward_wb2ex_rs2  = (dataram_wb_valid && wb_rd_wen_raw && (wb_reg_rd_addr != 0) &&
                             (wb_reg_rd_addr == ex_rs2_addr) &&
                             !forward_dataram2ex_rs2);

  // MEM->EX forwarding data:
  // - Load: forward memory read data
  // - Others: forward ALU result
  wire [31:0] dataram_forward_data = (ex_dataram_aluc == `L_TYPE) ? mem_result_data :
                                     ex_dataram_alu_result;

  assign ex_forwarded_rs1_data = forward_dataram2ex_rs1 ? dataram_forward_data :
                                      forward_wb2ex_rs1 ? wb_reg_rd_data :
                                      ex_rs1_data;
  wire [31:0] ex_forwarded_rs2_data = forward_dataram2ex_rs2 ? dataram_forward_data :
                                      forward_wb2ex_rs2 ? wb_reg_rd_data :
                                      ex_rs2_data;
  // ========== EX Stage: Execute ==========
  ex ex0 (
      .clk                     (clk),
      // Cancel a younger multi-cycle operation when an older access faults.
      .rst                     (rst || mem_trap_fire),
      .ex_can_advance          (ex_fire),
      .ex_operands_ready       (ex_valid && !ex_fetch_fault && !mem_wait && !mem_fault),
      .id_ex_jal_resolved      (ex_jal_resolved),
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
      .id_ex_predicted_pht_index(ex_predicted_pht_index),
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
      .ex_bp_update_wen        (ex_bp_update_wen),
      .ex_bp_update_pc         (ex_bp_update_pc),
      .ex_bp_update_taken      (ex_bp_update_taken),
      .ex_bp_update_target     (ex_bp_update_target),
      .ex_bp_update_pht_index  (ex_bp_update_pht_index),
      .ex_bp_event_branch      (ex_bp_event_branch),
      .ex_bp_event_mispredict  (ex_bp_event_mispredict),
      .ex_bp_event_target_miss (ex_bp_event_target_miss),
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
      .ex_pc             (id_ex_pc),
      .ex_dataram_addr   (ex_dataram_addr),
      .ex_dataram_wdata  (ex_dataram_wdata),
      .ex_valid          (ex_valid && !ex_instruction_trap && !mem_fault),
      .ex_rd_addr        (ex_reg_rd_addr),
      .ex_aluc           (ex_aluc),
      .ex_alucex         (ex_dataram_alucex),
      .ex_rd_wen         (ex_reg_rd_wen),
      .ex_dataram_wen    (ex_dataram_wen),
      .ex_dataram_ren    (ex_dataram_ren),
      .dataram_alu_result(ex_dataram_alu_result),
      .dataram_pc        (mem_instruction_pc),
      .dataram_addr      (dataram_addr),
      .dataram_wdata     (dataram_wdata),
      .dataram_valid     (ex_dataram_valid),
      .dataram_rd_addr   (ex_dataram_rd_addr),
      .dataram_aluc      (ex_dataram_aluc),
      .dataram_alucex    (dataram_alucex),
      .dataram_rd_wen    (ex_dataram_rd_wen),
      .dataram_wen       (dataram_wen),
      .dataram_ren       (dataram_ren)
  );

  // ========== MEM/WB Pipeline Register ==========
  dataram_wb_reg dataram_wb_reg0 (
      .clk               (clk),
      .rst               (rst),
      .stall             (stall_dataram_wb),
      .flush             (flush_dataram_wb),
      .dataram_alu_result(ex_dataram_alu_result),
      .dataram_load_data (mem_result_data),
      .dataram_rd_addr   (ex_dataram_rd_addr),
      .dataram_valid     (ex_dataram_valid),
      .dataram_aluc      (ex_dataram_aluc),
      .dataram_rd_wen    (ex_dataram_rd_wen),
      .wb_alu_result     (dataram_wb_alu_result),
      .wb_load_data      (dataram_wb_load_data),
      .wb_rd_addr        (dataram_wb_rd_addr),
      .wb_aluc           (dataram_wb_aluc),
      .wb_rd_wen         (dataram_wb_rd_wen),
      .wb_valid          (dataram_wb_valid)
  );

  // ========== WB Stage: Write Back ==========
  wb wb0 (
      .ex_wb_alu_result(dataram_wb_alu_result),
      .ex_wb_rd_addr   (dataram_wb_rd_addr),
      .ex_wb_rd_wen    (dataram_wb_rd_wen),
      .ex_wb_aluc      (dataram_wb_aluc),
      .dataram_wb_rdata(dataram_wb_load_data),
      .wb_reg_rd_data  (wb_reg_rd_data),
      .wb_reg_rd_addr  (wb_reg_rd_addr),
      .wb_reg_rd_wen   (wb_rd_wen_raw)
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
      .retire_pulse      (retire_pulse),
      .older_unretired   ({1'b0, ex_dataram_valid} + {1'b0, retire_pulse}),
      .ex_csr_wen        (ex_csr_wen && ex_fire),
      .ex_csr_ren        (ex_csr_ren),
      .ex_csr_is_csr     (ex_is_csr),
      .ex_csr_alucex     (ex_fire ? ex_csr_alucex : 8'b0),
      .ex_csr_addr       (csr_addr),
      .ex_csr_rs1_data   (ex_csr_rs1_data),
      .ex_csr_trap_valid (trap_fire),
      .ex_csr_trap_pc    (trap_pc),
      .ex_csr_trap_cause (trap_cause),
      .ex_csr_trap_tval  (trap_tval),
      .csr_ex_data       (csr_ex_data),
      .csr_ex_trap_vector(csr_ex_trap_vector),
      .csr_ex_mepc       (csr_ex_mepc),
      .csr_ex_illegal    (csr_ex_illegal)
  );

  // ========== Core Memory Path and Native Burst Arbitration ==========
  // 写回 DCache 的 FENCE.I 维护期间暂停流水线；Cache 与外部总线继续独立运行。

  // Native backend transactions: one word or a complete cache-line burst.
  // The word_* names are retained for existing waveform/verification scripts.
  wire [1:0] word_s_req_valid, word_s_req_ready, word_s_req_write;
  wire [1:0] word_s_rsp_valid, word_s_rsp_ready;
  wire [63:0] word_s_req_addr, word_s_req_wdata;
  wire [ 7:0] word_s_req_wstrb;
  wire [63:0] word_s_rsp_rdata;
  wire [1:0] word_s_rsp_error, word_s_rsp_last;
  wire [15:0] word_s_req_len;
  wire word_s_req_wlast;
  // Cache-facing native words: lane 0 = fetch adapter, lane 1 = LSU.
  // Lane 0 = instruction cache/bypass; lane 1 = data cache/bypass.
  wire [1:0] cache_cpu_req_valid, cache_cpu_req_ready, cache_cpu_req_write;
  wire [63:0] cache_cpu_req_addr, cache_cpu_req_wdata, cache_cpu_rsp_rdata;
  wire [7:0] cache_cpu_req_wstrb;
  wire [1:0] cache_cpu_rsp_valid, cache_cpu_rsp_ready, cache_cpu_rsp_error;
  wire [3:0] cache_cpu_rsp_source;
  wire [1:0] cache_maint_req_valid, cache_maint_req_ready;
  wire [1:0] cache_maint_done_valid, cache_maint_done_ready;
  reg icache_maint_pending;
  // clean_：FENCE.I 的 DCache clean -> ICache invalidate 顺序控制。
  // 只用寄存后的状态暂停 Core，避免与 Core 的 ex_fire 形成组合环。
  localparam [2:0] CLEAN_IDLE = 0, CLEAN_D_REQ = 1, CLEAN_D_WAIT = 2,
                   CLEAN_I_REQ = 3, CLEAN_I_WAIT = 4, CLEAN_FAILED = 5;
  reg [2:0] clean_state;
  wire d_clean_error;
  wire i_maint_start = (DCACHE_ENABLE != 0) ? (clean_state == CLEAN_I_REQ) : icache_invalidate;
  assign top_core_mem_stall = (DCACHE_ENABLE != 0) && (clean_state != CLEAN_IDLE);
  assign cache_maint_req_valid[0] = (ICACHE_ENABLE != 0) && (icache_maint_pending || i_maint_start);
  assign cache_maint_req_valid[1] = (DCACHE_ENABLE != 0) && (clean_state == CLEAN_D_REQ);
  assign cache_maint_done_ready = 2'b11;
  always @(posedge clk) begin
    if (rst) begin
      icache_maint_pending <= 1'b0;
      clean_state          <= CLEAN_IDLE;
    end else begin
      if (i_maint_start && ICACHE_ENABLE != 0) icache_maint_pending <= 1'b1;
      if (cache_maint_req_valid[0] && cache_maint_req_ready[0]) icache_maint_pending <= 1'b0;
      case (clean_state)
        CLEAN_IDLE: if (icache_invalidate && DCACHE_ENABLE != 0) clean_state <= CLEAN_D_REQ;
        CLEAN_D_REQ: if (cache_maint_req_ready[1]) clean_state <= CLEAN_D_WAIT;
        CLEAN_D_WAIT:
        if (cache_maint_done_valid[1])
          clean_state <= d_clean_error ? CLEAN_FAILED : ((ICACHE_ENABLE != 0) ? CLEAN_I_REQ : CLEAN_IDLE);
        CLEAN_I_REQ: if (cache_maint_req_ready[0]) clean_state <= CLEAN_I_WAIT;
        CLEAN_I_WAIT: if (cache_maint_done_valid[0]) clean_state <= CLEAN_IDLE;
        CLEAN_FAILED: clean_state <= CLEAN_FAILED;
        default: clean_state <= CLEAN_IDLE;
      endcase
    end
  end
  // clean 失败保留 Cache 脏数据并停住，不能继续执行可能陈旧的指令。
  // synthesis translate_off
  always @(posedge clk) begin
    if (!rst && clean_state == CLEAN_D_WAIT && cache_maint_done_valid[1] && d_clean_error)
      $fatal(1, "DCache clean failed during FENCE.I");
  end
  // synthesis translate_on
  assign backend_if_start = core_instrom_ren && if_req_ready;
  assign backend_if_addr  = core_instrom_addr;
  assign instrom_core_pc  = core_instrom_addr;
  mem_req_adapter data_adapter (
      .clk           (clk),
      .rst           (rst),
      .req_valid     (data_req_valid),
      .req_ready     (data_req_ready),
      .req_id        (data_req_id),
      .req_addr      (core_dataram_addr),
      .req_write     (core_dataram_wen),
      .req_wdata     (core_dataram_wdata),
      .req_alucex    (core_dataram_alucex),
      .rsp_valid     (data_rsp_valid),
      .rsp_ready     (data_rsp_ready),
      .rsp_id        (data_rsp_id),
      .rsp_rdata     (dataram_core_rdata),
      .rsp_error     (data_rsp_error),
      .rsp_fault_addr(data_rsp_fault_addr),
      .backend_start (backend_data_start),
      .backend_addr  (backend_data_addr),
      .backend_write (backend_data_write),
      .backend_wdata (backend_data_wdata),
      .backend_alucex(backend_data_alucex),
      .backend_busy  (backend_data_busy),
      .backend_rdata (backend_data_rdata),
      .backend_error (backend_data_error),
      .backend_fault_addr(backend_data_fault_addr)
  );
  fetch_mem_adapter fetch_port (
      .clk          (clk),
      .rst          (rst),
      .req_valid    (core_instrom_ren),
      .req_ready    (if_req_ready),
      .req_id       (if_req_id),
      .req_addr     (core_instrom_addr),
      .rsp_valid    (if_rsp_valid),
      .rsp_ready    (if_rsp_ready),
      .rsp_id       (if_rsp_id),
      .rsp_rdata    (instrom_core_data),
      .rsp_error    (if_rsp_error),
      .mem_req_valid(cache_cpu_req_valid[0]),
      .mem_req_ready(cache_cpu_req_ready[0]),
      .mem_req_addr (cache_cpu_req_addr[31:0]),
      .mem_rsp_valid(cache_cpu_rsp_valid[0]),
      .mem_rsp_ready(cache_cpu_rsp_ready[0]),
      .mem_rsp_rdata(cache_cpu_rsp_rdata[31:0]),
      .mem_rsp_error(cache_cpu_rsp_error[0])
  );
  assign cache_cpu_req_write[0]    = 1'b0;
  assign cache_cpu_req_wdata[31:0] = 32'b0;
  assign cache_cpu_req_wstrb[3:0]  = 4'b0;
  lsu data_lsu (
      .clk         (clk),
      .rst         (rst),
      .start       (backend_data_start),
      .addr        (backend_data_addr),
      .write_access(backend_data_write),
      .wdata       (backend_data_wdata),
      .alucex      (backend_data_alucex),
      .busy        (backend_data_busy),
      .rdata       (backend_data_rdata),
      .error       (backend_data_error),
      .fault_addr  (backend_data_fault_addr),
      .req_valid   (cache_cpu_req_valid[1]),
      .req_ready   (cache_cpu_req_ready[1]),
      .req_addr    (cache_cpu_req_addr[63:32]),
      .req_write   (cache_cpu_req_write[1]),
      .req_wdata   (cache_cpu_req_wdata[63:32]),
      .req_wstrb   (cache_cpu_req_wstrb[7:4]),
      .rsp_valid   (cache_cpu_rsp_valid[1]),
      .rsp_ready   (cache_cpu_rsp_ready[1]),
      .rsp_rdata   (cache_cpu_rsp_rdata[63:32]),
      .rsp_error   (cache_cpu_rsp_error[1])
  );
  // i_：取指侧；d_：数据侧。完整物理地址检查在两侧开关之前完成。
  wire [33:0] i_phys_addr, d_phys_addr;
  wire i_addr_valid, i_executable, i_cacheable, i_line_cacheable, i_is_mmio;
  wire d_addr_valid, d_cacheable, d_line_cacheable, d_is_mmio;
  wire i_access_ok, i_req_cacheable, d_access_ok, d_req_cacheable;
  // 旁路下游 ready 保留为核内信号，供零额外请求延迟检查使用。
  wire i_bypass_req_ready, d_bypass_req_ready;

  addr_translate_bypass i_translation (
      .effective_addr(cache_cpu_req_addr[31:0]),
      .phys_addr     (i_phys_addr)
  );
  mem_attr_decode #(
      .LINE_BYTES(64)
  ) i_attributes (
      .phys_addr     (i_phys_addr),
      .addr_valid    (i_addr_valid),
      .executable    (i_executable),
      .cacheable     (i_cacheable),
      .line_cacheable(i_line_cacheable),
      .is_mmio       (i_is_mmio)
  );

  addr_translate_bypass d_translation (
      .effective_addr(cache_cpu_req_addr[63:32]),
      .phys_addr     (d_phys_addr)
  );
  mem_attr_decode #(
      .LINE_BYTES(64)
  ) d_attributes (
      .phys_addr     (d_phys_addr),
      .addr_valid    (d_addr_valid),
      .executable    (),
      .cacheable     (d_cacheable),
      .line_cacheable(d_line_cacheable),
      .is_mmio       (d_is_mmio)
  );

  assign i_access_ok = i_addr_valid && (i_phys_addr[1:0] == 2'b00) &&
                       i_executable && !cache_cpu_req_write[0];
  assign d_access_ok = d_addr_valid && (d_phys_addr[1:0] == 2'b00);
  assign i_req_cacheable = i_access_ok && i_cacheable && i_line_cacheable;
  assign d_req_cacheable = d_access_ok && d_cacheable && d_line_cacheable;

  // 指令侧开关：开启使用已有 ICache 控制器，关闭使用字旁路。
  // 控制器内部保留不可缓存访问、错误处理和 FENCE.I 维护。
  generate
    if (ICACHE_ENABLE != 0) begin : g_icache
      assign i_bypass_req_ready = 1'b0;
      icache_phys_word #(
          .ICACHE_ENABLE(1)
      ) physical_port (
          .clk             (clk),
          .rst             (rst),
          .req_valid       (cache_cpu_req_valid[0]),
          .req_ready       (cache_cpu_req_ready[0]),
          .req_addr        (i_phys_addr),
          .req_write       (1'b0),
          .req_wdata       (32'b0),
          .req_wstrb       (4'b0),
          .req_access_ok   (i_access_ok),
          .req_cacheable   (i_req_cacheable),
          .rsp_valid       (cache_cpu_rsp_valid[0]),
          .rsp_ready       (cache_cpu_rsp_ready[0]),
          .rsp_rdata       (cache_cpu_rsp_rdata[31:0]),
          .rsp_error       (cache_cpu_rsp_error[0]),
          .rsp_source      (cache_cpu_rsp_source[1:0]),
          .mem_req_valid   (word_s_req_valid[0]),
          .mem_req_ready   (word_s_req_ready[0]),
          .mem_req_addr    (word_s_req_addr[31:0]),
          .mem_req_len     (word_s_req_len[7:0]),
          .mem_req_write   (word_s_req_write[0]),
          .mem_req_wdata   (word_s_req_wdata[31:0]),
          .mem_req_wstrb   (word_s_req_wstrb[3:0]),
          .mem_rsp_valid   (word_s_rsp_valid[0]),
          .mem_rsp_ready   (word_s_rsp_ready[0]),
          .mem_rsp_rdata   (word_s_rsp_rdata[31:0]),
          .mem_rsp_error   (word_s_rsp_error[0]),
          .mem_rsp_last    (word_s_rsp_last[0]),
          .maint_req_valid (cache_maint_req_valid[0]),
          .maint_req_ready (cache_maint_req_ready[0]),
          .maint_done_valid(cache_maint_done_valid[0]),
          .maint_done_ready(cache_maint_done_ready[0])
      );
    end else begin : g_i_bypass
      wire [33:0] bypass_addr;
      wire bypass_req_valid, bypass_req_write;
      wire [31:0] bypass_req_wdata;
      wire [ 3:0] bypass_req_wstrb;
      wire bypass_rsp_valid, bypass_rsp_ready, bypass_rsp_error;
      wire [31:0] bypass_rsp_rdata;

      cache_word_bypass #(
          .CACHE_ENABLE(0)
      ) boundary (
          .clk              (clk),
          .rst              (rst),
          .cpu_req_valid    (cache_cpu_req_valid[0]),
          .cpu_req_ready    (cache_cpu_req_ready[0]),
          .cpu_req_addr     (i_phys_addr),
          .cpu_req_write    (cache_cpu_req_write[0]),
          .cpu_req_wdata    (cache_cpu_req_wdata[31:0]),
          .cpu_req_wstrb    (cache_cpu_req_wstrb[3:0]),
          .cpu_req_access_ok(i_access_ok),
          .cpu_req_cacheable(i_req_cacheable),
          .cpu_rsp_valid    (cache_cpu_rsp_valid[0]),
          .cpu_rsp_ready    (cache_cpu_rsp_ready[0]),
          .cpu_rsp_rdata    (cache_cpu_rsp_rdata[31:0]),
          .cpu_rsp_error    (cache_cpu_rsp_error[0]),
          .cpu_rsp_source   (cache_cpu_rsp_source[1:0]),
          .mem_req_valid    (bypass_req_valid),
          .mem_req_ready    (i_bypass_req_ready),
          .mem_req_addr     (bypass_addr),
          .mem_req_write    (bypass_req_write),
          .mem_req_wdata    (bypass_req_wdata),
          .mem_req_wstrb    (bypass_req_wstrb),
          .mem_rsp_valid    (bypass_rsp_valid),
          .mem_rsp_ready    (bypass_rsp_ready),
          .mem_rsp_rdata    (bypass_rsp_rdata),
          .mem_rsp_error    (bypass_rsp_error),
          .maint_req_valid  (cache_maint_req_valid[0]),
          .maint_req_ready  (cache_maint_req_ready[0]),
          .maint_done_valid (cache_maint_done_valid[0]),
          .maint_done_ready (cache_maint_done_ready[0])
      );

      icache_phys_word #(
          .ICACHE_ENABLE(0)
      ) physical_port (
          .clk             (clk),
          .rst             (rst),
          .req_valid       (bypass_req_valid),
          .req_ready       (i_bypass_req_ready),
          .req_addr        (bypass_addr),
          .req_write       (bypass_req_write),
          .req_wdata       (bypass_req_wdata),
          .req_wstrb       (bypass_req_wstrb),
          .req_access_ok   (i_access_ok),
          .req_cacheable   (i_req_cacheable),
          .rsp_valid       (bypass_rsp_valid),
          .rsp_ready       (bypass_rsp_ready),
          .rsp_rdata       (bypass_rsp_rdata),
          .rsp_error       (bypass_rsp_error),
          .rsp_source      (),
          .mem_req_valid   (word_s_req_valid[0]),
          .mem_req_ready   (word_s_req_ready[0]),
          .mem_req_addr    (word_s_req_addr[31:0]),
          .mem_req_len     (word_s_req_len[7:0]),
          .mem_req_write   (word_s_req_write[0]),
          .mem_req_wdata   (word_s_req_wdata[31:0]),
          .mem_req_wstrb   (word_s_req_wstrb[3:0]),
          .mem_rsp_valid   (word_s_rsp_valid[0]),
          .mem_rsp_ready   (word_s_rsp_ready[0]),
          .mem_rsp_rdata   (word_s_rsp_rdata[31:0]),
          .mem_rsp_error   (word_s_rsp_error[0]),
          .mem_rsp_last    (word_s_rsp_last[0]),
          .maint_req_valid (1'b0),
          .maint_req_ready (),
          .maint_done_valid(),
          .maint_done_ready(1'b1)
      );
    end
  endgenerate

  // 数据侧开关：开启使用写回 DCache，关闭保留原有字旁路。
  generate
    if (DCACHE_ENABLE != 0) begin : g_dcache
      assign d_bypass_req_ready = 1'b0;
      dcache_phys_word #(
          .DCACHE_ENABLE(1)
      ) physical_port (
          .clk             (clk),
          .rst             (rst),
          .req_valid       (cache_cpu_req_valid[1]),
          .req_ready       (cache_cpu_req_ready[1]),
          .req_addr        (d_phys_addr),
          .req_write       (cache_cpu_req_write[1]),
          .req_wdata       (cache_cpu_req_wdata[63:32]),
          .req_wstrb       (cache_cpu_req_wstrb[7:4]),
          .req_access_ok   (d_access_ok),
          .req_cacheable   (d_req_cacheable),
          .rsp_valid       (cache_cpu_rsp_valid[1]),
          .rsp_ready       (cache_cpu_rsp_ready[1]),
          .rsp_rdata       (cache_cpu_rsp_rdata[63:32]),
          .rsp_error       (cache_cpu_rsp_error[1]),
          .rsp_source      (cache_cpu_rsp_source[3:2]),
          .mem_req_valid   (word_s_req_valid[1]),
          .mem_req_ready   (word_s_req_ready[1]),
          .mem_req_addr    (word_s_req_addr[63:32]),
          .mem_req_len     (word_s_req_len[15:8]),
          .mem_req_write   (word_s_req_write[1]),
          .mem_req_wlast   (word_s_req_wlast),
          .mem_req_wdata   (word_s_req_wdata[63:32]),
          .mem_req_wstrb   (word_s_req_wstrb[7:4]),
          .mem_rsp_valid   (word_s_rsp_valid[1]),
          .mem_rsp_ready   (word_s_rsp_ready[1]),
          .mem_rsp_rdata   (word_s_rsp_rdata[63:32]),
          .mem_rsp_error   (word_s_rsp_error[1]),
          .mem_rsp_rlast   (word_s_rsp_last[1]),
          .maint_req_valid (cache_maint_req_valid[1]),
          .maint_req_ready (cache_maint_req_ready[1]),
          .maint_done_valid(cache_maint_done_valid[1]),
          .maint_done_ready(cache_maint_done_ready[1]),
          .maint_error     (d_clean_error)
      );
    end else begin : g_d_bypass
      assign d_clean_error = 1'b0;
      wire [33:0] bypass_addr;
      wire bypass_req_valid, bypass_req_write;
      wire [31:0] bypass_req_wdata;
      wire [ 3:0] bypass_req_wstrb;
      wire bypass_rsp_valid, bypass_rsp_ready, bypass_rsp_error;
      wire [31:0] bypass_rsp_rdata;

      cache_word_bypass #(
          .CACHE_ENABLE(0)
      ) boundary (
          .clk              (clk),
          .rst              (rst),
          .cpu_req_valid    (cache_cpu_req_valid[1]),
          .cpu_req_ready    (cache_cpu_req_ready[1]),
          .cpu_req_addr     (d_phys_addr),
          .cpu_req_write    (cache_cpu_req_write[1]),
          .cpu_req_wdata    (cache_cpu_req_wdata[63:32]),
          .cpu_req_wstrb    (cache_cpu_req_wstrb[7:4]),
          .cpu_req_access_ok(d_access_ok),
          .cpu_req_cacheable(d_req_cacheable),
          .cpu_rsp_valid    (cache_cpu_rsp_valid[1]),
          .cpu_rsp_ready    (cache_cpu_rsp_ready[1]),
          .cpu_rsp_rdata    (cache_cpu_rsp_rdata[63:32]),
          .cpu_rsp_error    (cache_cpu_rsp_error[1]),
          .cpu_rsp_source   (cache_cpu_rsp_source[3:2]),
          .mem_req_valid    (bypass_req_valid),
          .mem_req_ready    (d_bypass_req_ready),
          .mem_req_addr     (bypass_addr),
          .mem_req_write    (bypass_req_write),
          .mem_req_wdata    (bypass_req_wdata),
          .mem_req_wstrb    (bypass_req_wstrb),
          .mem_rsp_valid    (bypass_rsp_valid),
          .mem_rsp_ready    (bypass_rsp_ready),
          .mem_rsp_rdata    (bypass_rsp_rdata),
          .mem_rsp_error    (bypass_rsp_error),
          .maint_req_valid  (cache_maint_req_valid[1]),
          .maint_req_ready  (cache_maint_req_ready[1]),
          .maint_done_valid (cache_maint_done_valid[1]),
          .maint_done_ready (cache_maint_done_ready[1])
      );

      dcache_phys_word #(
          .DCACHE_ENABLE(0)
      ) physical_port (
          .clk             (clk),
          .rst             (rst),
          .req_valid       (bypass_req_valid),
          .req_ready       (d_bypass_req_ready),
          .req_addr        (bypass_addr),
          .req_write       (bypass_req_write),
          .req_wdata       (bypass_req_wdata),
          .req_wstrb       (bypass_req_wstrb),
          .req_access_ok   (d_access_ok),
          .req_cacheable   (d_req_cacheable),
          .rsp_valid       (bypass_rsp_valid),
          .rsp_ready       (bypass_rsp_ready),
          .rsp_rdata       (bypass_rsp_rdata),
          .rsp_error       (bypass_rsp_error),
          .rsp_source      (),
          .mem_req_valid   (word_s_req_valid[1]),
          .mem_req_ready   (word_s_req_ready[1]),
          .mem_req_addr    (word_s_req_addr[63:32]),
          .mem_req_len     (word_s_req_len[15:8]),
          .mem_req_write   (word_s_req_write[1]),
          .mem_req_wlast   (word_s_req_wlast),
          .mem_req_wdata   (word_s_req_wdata[63:32]),
          .mem_req_wstrb   (word_s_req_wstrb[7:4]),
          .mem_rsp_valid   (word_s_rsp_valid[1]),
          .mem_rsp_ready   (word_s_rsp_ready[1]),
          .mem_rsp_rdata   (word_s_rsp_rdata[63:32]),
          .mem_rsp_error   (word_s_rsp_error[1]),
          .mem_rsp_rlast   (word_s_rsp_last[1]),
          .maint_req_valid (1'b0),
          .maint_req_ready (),
          .maint_done_valid(),
          .maint_done_ready(1'b1),
          .maint_error     ()
      );
    end
  endgenerate
  mem_burst_arbiter word_arbiter (
      .s_req_valid(word_s_req_valid), .s_req_ready(word_s_req_ready),
      .s_req_addr(word_s_req_addr), .s_req_len(word_s_req_len), .s_req_write(word_s_req_write),
      .s_req_wdata(word_s_req_wdata), .s_req_wstrb(word_s_req_wstrb), .s_req_wlast(word_s_req_wlast),
      .s_rsp_valid(word_s_rsp_valid), .s_rsp_ready(word_s_rsp_ready),
      .s_rsp_rdata(word_s_rsp_rdata), .s_rsp_error(word_s_rsp_error), .s_rsp_last(word_s_rsp_last),
      .clk(clk), .rst(rst),
      .rd_req_valid(mem_rd_req_valid), .rd_req_ready(mem_rd_req_ready),
      .rd_req_addr(mem_rd_req_addr), .rd_req_len(mem_rd_req_len),
      .rd_rsp_valid(mem_rd_rsp_valid), .rd_rsp_ready(mem_rd_rsp_ready),
      .rd_rsp_rdata(mem_rd_rsp_rdata), .rd_rsp_error(mem_rd_rsp_error), .rd_rsp_last(mem_rd_rsp_last),
      .wr_req_valid(mem_wr_req_valid), .wr_req_ready(mem_wr_req_ready),
      .wr_req_addr(mem_wr_req_addr), .wr_req_len(mem_wr_req_len),
      .wr_req_wdata(mem_wr_req_wdata), .wr_req_wstrb(mem_wr_req_wstrb), .wr_req_wlast(mem_wr_req_wlast),
      .wr_rsp_valid(mem_wr_rsp_valid), .wr_rsp_ready(mem_wr_rsp_ready), .wr_rsp_error(mem_wr_rsp_error)
  );

endmodule
