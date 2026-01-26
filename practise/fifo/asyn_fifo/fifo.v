module fifo #(
    parameter DATA_BIT_WIDTH = 8,
    parameter DATA_DEPTH     = 16
) (
    input rst,

    // Write Interface
    input                      w_clk,
    input                      wen,
    input [DATA_BIT_WIDTH-1:0] wdata,

    // Read Interface
    input                       r_clk,
    input                       ren,
    output [DATA_BIT_WIDTH-1:0] rdata,

    // Status Interface
    output full,
    output empty
    // --- 修复点：直接在这里计算位宽 ---
    // 深度为16时，log2(16)=4。计数器需要能存下16(10000)，即5位([4:0])。
);

  // 内部参数定义
  localparam ADDR_WIDTH = $clog2(DATA_DEPTH);  // 例如 4
  localparam PTR_WIDTH = ADDR_WIDTH + 1;  // 例如 5

  reg [PTR_WIDTH-1 : 0] w_bin, r_bin;  // read and write ptr
  wire [PTR_WIDTH-1 : 0] w_bin_next, r_bin_next;
  reg [PTR_WIDTH-1 : 0] w_gray, r_gray;
  wire [PTR_WIDTH-1 : 0] w_gray_next, r_gray_next;
  reg [PTR_WIDTH-1 : 0] w2r_meta, r2w_meta;  // meta 表示亚稳态
  reg [PTR_WIDTH-1 : 0] w2r_safe, r2w_safe;  // safe 表嫂稳定态

  assign w_bin_next  = w_bin + (wen && !full);
  assign r_bin_next  = r_bin + (ren && !empty);
  assign w_gray_next = (w_bin_next >> 1) ^ w_bin_next;
  assign r_gray_next = (r_bin_next >> 1) ^ r_bin_next;
  // 写指针
  always @(posedge w_clk) begin
    if (rst) begin
      w_bin  <= 0;
      w_gray <= 0;
    end else begin
      w_bin  <= w_bin_next;
      w_gray <= w_gray_next;
    end
  end

  // 读指针
  always @(posedge r_clk) begin
    if (rst) begin
      r_bin  <= 0;
      r_gray <= 0;
    end else begin
      r_bin  <= r_bin_next;
      r_gray <= r_gray_next;
    end
  end

  //不同时域的指针相互转化
  always @(posedge r_clk) begin
    if (rst) begin
      w2r_safe <= 0;
      w2r_meta <= 0;
    end else begin
      w2r_meta <= w_gray;
      w2r_safe <= w2r_meta;
    end
  end

  always @(posedge w_clk) begin
    if (rst) begin
      r2w_safe <= 0;
      r2w_meta <= 0;
    end else begin
      r2w_meta <= r_gray;
      r2w_safe <= r2w_meta;
    end
  end

  //空信号和满信号的产生
  assign full = (w_gray[PTR_WIDTH-1] != r2w_safe[PTR_WIDTH-1]) &&
                  (w_gray[PTR_WIDTH-2] != r2w_safe[PTR_WIDTH-2]) &&
                  (w_gray[ADDR_WIDTH-2:0] == r2w_safe[ADDR_WIDTH-2:0]);
  assign empty = (w2r_safe == r_gray);  //空信号一定在读时钟域产生

  // --- RAM 实例化 ---
  // 确保你的 ram.v 也是修正后的版本
  ram #(
      .DATA_BIT_WIDTH  (DATA_BIT_WIDTH),
      .DATA_DEPTH      (DATA_DEPTH),
      .DATA_DEPTH_WIDTH(ADDR_WIDTH)
  ) ram_inst (
      .r_clk(r_clk),
      .w_clk(w_clk),
      // .rst (rst), // 如果你的 RAM 不需要复位，这行可以注释掉；如果加了复位逻辑则保留

      .wen  (wen && !full),
      .waddr(w_bin[ADDR_WIDTH-1:0]),
      .wdata(wdata),

      .ren  (ren && !empty),
      .raddr(r_bin[ADDR_WIDTH-1:0]),
      .rdata(rdata)
  );

endmodule
