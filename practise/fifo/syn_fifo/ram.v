module ram #(
    parameter DATA_BIT_WIDTH   = 8,
    parameter DATA_DEPTH       = 16,
    parameter DATA_DEPTH_WIDTH = 4
) (
    input clk,
    // input rst, // 建议移除：RAM 通常不需要复位

    // 写端口
    input                        wen,
    input [DATA_DEPTH_WIDTH-1:0] waddr,  // 修正：范围必须是 [N-1 : 0]
    input [  DATA_BIT_WIDTH-1:0] wdata,

    // 读端口
    input                             ren,
    input      [DATA_DEPTH_WIDTH-1:0] raddr,
    output reg [  DATA_BIT_WIDTH-1:0] rdata   // 修正：添加 reg 且修复位宽
);

  // 声明内存数组
  // 格式：reg [位宽] 名字 [深度]
  reg [DATA_BIT_WIDTH-1:0] mem[0:DATA_DEPTH-1];

  // --- 写逻辑 ---
  always @(posedge clk) begin
    if (wen) begin
      mem[waddr] <= wdata;
    end
  end

  // --- 读逻辑 ---
  always @(posedge clk) begin
    if (ren) begin
      rdata <= mem[raddr];
    end
    // 如果你需要 rst 复位输出端口的数据（而不是复位整个RAM数组），可以写在这里：
    // else if (rst) rdata <= 0;
    // 但通常为了性能，BRAM 的输出端也不加复位。
  end

endmodule
