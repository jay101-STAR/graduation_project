// `include "pc.v"
module openmips (
    input clk,
    input rst,

    input  [31:0] instrom_openmips_data,
    output [31:0] openmips_instrom_addr,
    output        openmips_instrom_ren,
    output [31:0] tohost_value
);
  //connect pc to id
  wire [31:0] pc_id_pc;

  //connect id to regsterfile
  wire [31:0] reg_id_rs1_data, reg_id_rs2_data;

  //connect regsterfile to id
  wire id_reg_rs1_ren, id_reg_rs2_ren;
  wire [4 : 0] id_reg_rs1_addr, id_reg_rs2_addr;

  //connect id to ex
  wire [31:0] id_ex_rs1_data, id_ex_rs2_data;
  wire         id_ex_rd_wen;
  wire [4 : 0] id_ex_rd_addr;
  wire [3 : 0] id_ex_aluc;
  wire [7 : 0] id_ex_alucex;
  wire [ 31:0] id_ex_pc;
  wire [  4:0] id_ex_rs1_addr;
  wire [ 11:0] id_ex_csr_addr;
  wire         id_ex_is_csr;
  wire         id_ex_branch_taken;

  //connect ex to csr
  wire         ex_csr_wen;
  wire         ex_csr_ren;
  wire [  7:0] ex_csr_alucex;
  wire [ 11:0] ex_csr_addr;
  wire [ 31:0] ex_csr_rs1_data;
  wire         ex_csr_trap_valid;
  wire [ 31:0] ex_csr_trap_pc;
  wire [ 31:0] ex_csr_trap_cause;

  //connect csr to ex
  wire [ 31:0] csr_ex_data;
  wire [ 31:0] csr_ex_trap_vector;
  wire [ 31:0] csr_ex_mepc;
  //connect ex to regsterfile
  wire [ 31:0] ex_reg_rd_data;
  wire [4 : 0] ex_reg_rd_addr;
  wire         ex_reg_rd_wen;

  //connect ex to pc
  wire         ex_pc_pc_wen;
  wire [ 31:0] ex_pc_pc_data;

  //connect ex to dataram
  wire [ 31:0] ex_dataram_addr;
  wire [ 31:0] ex_dataram_wdata;
  wire         ex_dataram_wen;
  wire         ex_dataram_ren;
  wire [  7:0] ex_dataram_alucex;

  //connect dataram to ex
  wire [ 31:0] dataram_ex_rdata;


  pc pc0 (
      .clk          (clk),
      .rst          (rst),
      .ren          (openmips_instrom_ren),
      .ex_pc_pc_wen (ex_pc_pc_wen),
      .ex_pc_pc_data(ex_pc_pc_data),
      .next_pc      (openmips_instrom_addr),
      .pc_id_pc     (pc_id_pc)
  );

  id id0 (
      .id_inst           (instrom_openmips_data),
      .pc_id_pc          (pc_id_pc),
      .reg_id_rs1_data   (reg_id_rs1_data),
      .reg_id_rs2_data   (reg_id_rs2_data),
      .id_reg_rs1_ren    (id_reg_rs1_ren),
      .id_reg_rs2_ren    (id_reg_rs2_ren),
      .id_reg_rs1_addr   (id_reg_rs1_addr),
      .id_reg_rs2_addr   (id_reg_rs2_addr),
      .id_ex_rs1_data    (id_ex_rs1_data),
      .id_ex_rs2_data    (id_ex_rs2_data),
      .id_ex_rd_wen      (id_ex_rd_wen),
      .id_ex_rd_addr     (id_ex_rd_addr),
      .id_ex_aluc        (id_ex_aluc),
      .id_ex_alucex      (id_ex_alucex),
      .id_ex_pc          (id_ex_pc),
      .id_ex_rs1_addr    (id_ex_rs1_addr),
      .id_ex_csr_addr    (id_ex_csr_addr),
      .id_ex_is_csr      (id_ex_is_csr),
      .id_ex_branch_taken(id_ex_branch_taken)
  );

  ex ex0 (
      .id_ex_aluc        (id_ex_aluc),
      .id_ex_alucex      (id_ex_alucex),
      .id_ex_rd_addr     (id_ex_rd_addr),
      .id_ex_rd_wen      (id_ex_rd_wen),
      .id_ex_rs1_data    (id_ex_rs1_data),
      .id_ex_rs2_data    (id_ex_rs2_data),
      .id_ex_rs1_addr    (id_ex_rs1_addr),
      .id_ex_pc          (id_ex_pc),
      .id_ex_branch_taken(id_ex_branch_taken),
      .id_ex_csr_addr    (id_ex_csr_addr),
      .id_ex_is_csr      (id_ex_is_csr),
      // CSR inputs from csr module
      .csr_ex_data       (csr_ex_data),
      .csr_ex_trap_vector(csr_ex_trap_vector),
      .csr_ex_mepc       (csr_ex_mepc),
      // dataram input
      .dataram_ex_rdata  (dataram_ex_rdata),
      // outputs to register file
      .ex_reg_rd_wen     (ex_reg_rd_wen),
      .ex_reg_rd_data    (ex_reg_rd_data),
      .ex_reg_rd_addr    (ex_reg_rd_addr),
      // outputs to PC
      .ex_pc_pc_wen      (ex_pc_pc_wen),
      .ex_pc_pc_data     (ex_pc_pc_data),
      // outputs to CSR module
      .ex_csr_wen        (ex_csr_wen),
      .ex_csr_ren        (ex_csr_ren),
      .ex_csr_alucex     (ex_csr_alucex),
      .ex_csr_csr_addr   (ex_csr_addr),
      .ex_csr_rs1_data   (ex_csr_rs1_data),
      .ex_csr_trap_pc    (ex_csr_trap_pc),
      .ex_csr_trap_valid (ex_csr_trap_valid),
      .ex_csr_trap_cause (ex_csr_trap_cause),
      // outputs to dataram
      .ex_dataram_addr   (ex_dataram_addr),
      .ex_dataram_wdata  (ex_dataram_wdata),
      .ex_dataram_wen    (ex_dataram_wen),
      .ex_dataram_ren    (ex_dataram_ren),
      .ex_dataram_alucex (ex_dataram_alucex)
  );

  chj_registerfile registerfile0 (
      .clk         (clk),
      .rst         (rst),
      .wdata       (ex_reg_rd_data),
      .waddr       (ex_reg_rd_addr),
      .wen         (ex_reg_rd_wen),
      .rs1_ren     (id_reg_rs1_ren),
      .rs1_raddr   (id_reg_rs1_addr),
      .rs2_ren     (id_reg_rs2_ren),
      .rs2_raddr   (id_reg_rs2_addr),
      .rs1_rdata   (reg_id_rs1_data),
      .rs2_rdata   (reg_id_rs2_data),
      .tohost_value(tohost_value)
  );

  csr csr0 (
      .clk               (clk),
      .rst               (rst),
      // CSR instruction interface (from EX)
      .ex_csr_wen        (ex_csr_wen),
      .ex_csr_ren        (ex_csr_ren),
      .ex_csr_alucex     (ex_csr_alucex),
      .ex_csr_addr       (ex_csr_addr),
      .ex_csr_rs1_data   (ex_csr_rs1_data),
      // trap / mret
      .ex_csr_trap_valid (ex_csr_trap_valid),
      .ex_csr_trap_pc    (ex_csr_trap_pc),
      .ex_csr_trap_cause (ex_csr_trap_cause),
      // outputs to EX
      .csr_ex_data       (csr_ex_data),
      .csr_ex_trap_vector(csr_ex_trap_vector),
      .csr_ex_mepc       (csr_ex_mepc)
  );

  dataram dataram0 (
      .clk              (clk),
      .rst              (rst),
      .ex_dataram_addr  (ex_dataram_addr),
      .ex_dataram_wdata (ex_dataram_wdata),
      .ex_dataram_wen   (ex_dataram_wen),
      .ex_dataram_ren   (ex_dataram_ren),
      .ex_dataram_alucex(ex_dataram_alucex),
      .dataram_ex_rdata (dataram_ex_rdata)
  );


endmodule

