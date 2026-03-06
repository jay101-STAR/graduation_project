//============================================================================
// std_bram_tdp.v - Standard true dual-port BRAM model
//============================================================================
// Features:
// - Shared memory array with two independent synchronous ports
// - Byte write-enable on each port (we[3:0])
// - Synchronous read on each port
// - Optional HEX initialization file (supports @address in readmemh)
//============================================================================

module std_bram_tdp #(
    parameter ADDR_WIDTH = 13,
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = (1 << ADDR_WIDTH),
    parameter HEX_FILE   = ""
) (
    input                       clk,
    input      [           3:0] a_we,
    input      [ADDR_WIDTH-1:0] a_addr,
    input      [DATA_WIDTH-1:0] a_wdata,
    output reg [DATA_WIDTH-1:0] a_rdata,
    input      [           3:0] b_we,
    input      [ADDR_WIDTH-1:0] b_addr,
    input      [DATA_WIDTH-1:0] b_wdata,
    output reg [DATA_WIDTH-1:0] b_rdata
);

  (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];

  integer i;
  initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
      mem[i] = {DATA_WIDTH{1'b0}};
    end
    if (HEX_FILE != "") begin
      $readmemh(HEX_FILE, mem);
    end
  end

  always @(posedge clk) begin
    if (a_we[0]) mem[a_addr][7:0] <= a_wdata[7:0];
    if (a_we[1]) mem[a_addr][15:8] <= a_wdata[15:8];
    if (a_we[2]) mem[a_addr][23:16] <= a_wdata[23:16];
    if (a_we[3]) mem[a_addr][31:24] <= a_wdata[31:24];
    a_rdata <= mem[a_addr];
  end

  always @(posedge clk) begin
    if (b_we[0]) mem[b_addr][7:0] <= b_wdata[7:0];
    if (b_we[1]) mem[b_addr][15:8] <= b_wdata[15:8];
    if (b_we[2]) mem[b_addr][23:16] <= b_wdata[23:16];
    if (b_we[3]) mem[b_addr][31:24] <= b_wdata[31:24];
    b_rdata <= mem[b_addr];
  end

endmodule
