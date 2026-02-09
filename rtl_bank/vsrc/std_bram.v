//============================================================================
// std_bram.v - 标准单口 BRAM 原语
//============================================================================
// 特性：
// - 使用 (* ram_style = "block" *) 强制综合为 Block RAM
// - 同步写入，支持字节掩码 (we[3:0])
// - 同步读取（读取地址在时钟边沿锁存，下一周期输出数据）
// - 参数化 HEX 文件名用于初始化
//============================================================================

module std_bram #(
    parameter ADDR_WIDTH      = 13,                 // 地址宽度，13位 = 8192 字 = 32KB
    parameter DATA_WIDTH      = 32,                 // 数据宽度
    parameter DEPTH           = (1 << ADDR_WIDTH),  // 存储深度
    parameter HEX_FILE        = "",                 // 初始化 HEX 文件路径,
    parameter INITIAL_ADDRESS = 1024
) (
    input                       clk,
    input      [           3:0] we,     // 字节写使能 [3:0]
    input      [ADDR_WIDTH-1:0] addr,   // 字地址
    input      [DATA_WIDTH-1:0] wdata,  // 写数据
    output reg [DATA_WIDTH-1:0] rdata   // 读数据（同步输出）
);

  // 强制使用 Block RAM
  (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];

  // 初始化
  integer i;
  initial begin
    // 先清零
    for (i = 0; i < DEPTH; i = i + 1) begin
      mem[i] = {DATA_WIDTH{1'b0}};
    end
    // 如果指定了 HEX 文件，则加载
    if (HEX_FILE != "") begin
      $readmemh(HEX_FILE, mem, INITIAL_ADDRESS);
    end
  end

  // 同步写入（带字节掩码）
  always @(posedge clk) begin
    if (we[0]) mem[addr][7:0] <= wdata[7:0];
    if (we[1]) mem[addr][15:8] <= wdata[15:8];
    if (we[2]) mem[addr][23:16] <= wdata[23:16];
    if (we[3]) mem[addr][31:24] <= wdata[31:24];
  end

  // 同步读取
  always @(posedge clk) begin
    rdata <= mem[addr];
  end

endmodule
