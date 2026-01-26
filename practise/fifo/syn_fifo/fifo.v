module fifo #(
    parameter DATA_BIT_WIDTH = 8,
    parameter DATA_DEPTH     = 16
) (
    input clk,
    input rst,

    // Write Interface
    input                      wen,
    input [DATA_BIT_WIDTH-1:0] wdata,

    // Read Interface
    input                       ren,
    output [DATA_BIT_WIDTH-1:0] rdata,

    // Status Interface
    output full,
    output empty,

    // --- 修复点：直接在这里计算位宽 ---
    // 深度为16时，log2(16)=4。计数器需要能存下16(10000)，即5位([4:0])。
    output [$clog2(DATA_DEPTH):0] data_count
);

  // 内部参数定义
  localparam ADDR_WIDTH = $clog2(DATA_DEPTH);  // 例如 4
  localparam PTR_WIDTH = ADDR_WIDTH + 1;  // 例如 5

  reg [PTR_WIDTH-1 : 0] w_ptr, r_ptr;

  // --- 指针逻辑 ---

  // 写指针
  always @(posedge clk) begin
    if (rst) begin
      w_ptr <= 0;
    end else if (wen && !full) begin
      w_ptr <= w_ptr + 1'b1;
    end
  end

  // 读指针
  always @(posedge clk) begin
    if (rst) begin
      r_ptr <= 0;
    end else if (ren && !empty) begin
      r_ptr <= r_ptr + 1'b1;
    end
  end

  // --- 状态标志逻辑 ---

  assign full  = (w_ptr[PTR_WIDTH-1] != r_ptr[PTR_WIDTH-1]) && 
                   (w_ptr[ADDR_WIDTH-1:0] == r_ptr[ADDR_WIDTH-1:0]);

  assign empty = (w_ptr == r_ptr);

  // 计算当前 FIFO 内的数据量
  assign data_count = w_ptr - r_ptr;

  // --- RAM 实例化 ---
  // 确保你的 ram.v 也是修正后的版本
  ram #(
      .DATA_BIT_WIDTH  (DATA_BIT_WIDTH),
      .DATA_DEPTH      (DATA_DEPTH),
      .DATA_DEPTH_WIDTH(ADDR_WIDTH)
  ) ram_inst (
      .clk(clk),
      // .rst (rst), // 如果你的 RAM 不需要复位，这行可以注释掉；如果加了复位逻辑则保留

      .wen  (wen && !full),
      .waddr(w_ptr[ADDR_WIDTH-1:0]),
      .wdata(wdata),

      .ren  (ren && !empty),
      .raddr(r_ptr[ADDR_WIDTH-1:0]),
      .rdata(rdata)
  );

endmodule
