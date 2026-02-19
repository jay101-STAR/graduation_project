`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
module instrom (
    input         clk,
    input         core_instrom_ren,
    input  [31:0] core_instrom_addr,
    input         instrom_patch_wen,
    input  [ 3:0] instrom_patch_wstrb,
    input  [31:0] instrom_patch_addr,
    input  [31:0] instrom_patch_wdata,
    output [31:0] instrom_core_data,
    output [31:0] instrom_core_pc
);
  localparam INST_ADDR_WIDTH = 14;  // 64KB / 4B = 16384 words
  localparam [31:0] INSTROM_SIZE_BYTES = (1 << (INST_ADDR_WIDTH + 2));

  wire [31:0] instrom_byte_offset;
  wire [INST_ADDR_WIDTH-1:0] instrom_word_addr;
  wire [31:0] instrom_core_data_raw;
  wire [31:0] instrom_patch_offset;
  wire [INST_ADDR_WIDTH-1:0] instrom_patch_word_addr;
  wire [3:0] instrom_patch_we;
  wire instrom_patch_in_range;
  wire [31:0] instrom_patch_rdata_unused;
  reg  [31:0] instrom_core_pc_raw = `PC_BASE_ADDR;

  // Keep read address stable before fetch enable is asserted.
  assign instrom_byte_offset = core_instrom_ren ? (core_instrom_addr - `PC_BASE_ADDR) : 32'b0;
  assign instrom_word_addr = instrom_byte_offset[INST_ADDR_WIDTH+1:2];
  assign instrom_patch_in_range = instrom_patch_wen &&
                                  (instrom_patch_addr >= `PC_BASE_ADDR) &&
                                  (instrom_patch_addr < (`PC_BASE_ADDR + INSTROM_SIZE_BYTES));
  assign instrom_patch_offset = instrom_patch_addr - `PC_BASE_ADDR;
  assign instrom_patch_word_addr = instrom_patch_offset[INST_ADDR_WIDTH+1:2];
  assign instrom_patch_we = instrom_patch_in_range ? instrom_patch_wstrb : 4'b0000;

  std_bram_tdp #(
      .ADDR_WIDTH(INST_ADDR_WIDTH),
      .DATA_WIDTH(32),
      .HEX_FILE  ("/home/jay/Desktop/graduation_project/rtl/vsrc/instrom/instrom.hex")
  ) instrom_bram (
      .clk    (clk),
      .a_we   (4'b0000),
      .a_addr (instrom_word_addr),
      .a_wdata(32'b0),
      .a_rdata(instrom_core_data_raw),
      .b_we   (instrom_patch_we),
      .b_addr (instrom_patch_word_addr),
      .b_wdata(instrom_patch_wdata),
      .b_rdata(instrom_patch_rdata_unused)
  );

  assign instrom_core_data = instrom_core_data_raw;
  assign instrom_core_pc = instrom_core_pc_raw;

  // Keep the fetch PC aligned with BRAM return beat.
  always @(posedge clk) begin
    if (core_instrom_ren) begin
      instrom_core_pc_raw <= core_instrom_addr;
    end
  end
endmodule
