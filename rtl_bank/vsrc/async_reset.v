`timescale 1ns / 1ns

// 异步复位同步释放模块（高有效）
// 输入：clk - 时钟信号
//       async_rst - 异步高有效复位信号
// 输出：sync_rst - 同步复位信号（高有效）
module async_reset (
    input  wire clk,
    input  wire async_rst,  // 异步高有效复位
    output wire sync_rst    // 同步高有效复位
);

  reg [2:0] rst_sync_reg;

  // 异步复位同步释放电路
  always @(posedge clk or posedge async_rst) begin
    if (async_rst) begin
      rst_sync_reg <= 3'b111;  // 异步复位时全部置1
    end else begin
      rst_sync_reg <= {rst_sync_reg[1:0], 1'b0};  // 同步释放
    end
  end

  // 同步复位信号输出
  assign sync_rst = rst_sync_reg[2];

endmodule

