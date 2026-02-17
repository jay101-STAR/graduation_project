`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
module instrom (
    input         clk,
    input         core_instrom_ren,
    input  [31:0] core_instrom_addr,
    output [31:0] instrom_core_data,
    output [31:0] instrom_core_pc
);
  localparam INST_ADDR_WIDTH = 14;  // 64KB / 4B = 16384 words

  wire [31:0] instrom_byte_offset;
  wire [INST_ADDR_WIDTH-1:0] instrom_word_addr;
  wire [31:0] instrom_core_data_raw;
  reg  [31:0] instrom_core_pc_raw = `PC_BASE_ADDR;

  // Keep read address stable before fetch enable is asserted.
  assign instrom_byte_offset = core_instrom_ren ? (core_instrom_addr - `PC_BASE_ADDR) : 32'b0;
  assign instrom_word_addr = instrom_byte_offset[INST_ADDR_WIDTH+1:2];

  std_bram #(
      .ADDR_WIDTH(INST_ADDR_WIDTH),
      .DATA_WIDTH(32),
      .HEX_FILE  ("/home/jay/Desktop/graduation_project/rtl/vsrc/instrom/instrom.hex")
  ) instrom_bram (
      .clk  (clk),
      .we   (4'b0000),
      .addr (instrom_word_addr),
      .wdata(32'b0),
      .rdata(instrom_core_data_raw)
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
