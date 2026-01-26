`timescale 1ns / 1ns

module tb_fifo;

  // --- 1. 参数定义 ---
  parameter DATA_BIT_WIDTH = 8;
  parameter DATA_DEPTH = 16;

  // --- 2. 信号声明 ---
  reg rst;

  // 写端口信号
  reg w_clk;
  reg wen;
  reg [DATA_BIT_WIDTH-1:0] wdata;

  // 读端口信号
  reg r_clk;
  reg ren;
  wire [DATA_BIT_WIDTH-1:0] rdata;

  // 状态信号
  wire full;
  wire empty;

  // 验证用变量
  integer i;
  reg [DATA_BIT_WIDTH-1:0] expected_data;

  // --- 3. 实例化待测模块 (DUT) ---
  fifo #(
      .DATA_BIT_WIDTH(DATA_BIT_WIDTH),
      .DATA_DEPTH    (DATA_DEPTH)
  ) u_fifo (
      .rst(rst),

      .w_clk(w_clk),
      .wen  (wen),
      .wdata(wdata),

      .r_clk(r_clk),
      .ren  (ren),
      .rdata(rdata),

      .full (full),
      .empty(empty)
  );

  // --- 4. 时钟生成 (模拟异步环境) ---
  // 写时钟：10ns 周期 (100 MHz)
  initial w_clk = 0;
  always #5 w_clk = ~w_clk;

  // 读时钟：16ns 周期 (62.5 MHz)
  initial r_clk = 0;
  always #8 r_clk = ~r_clk;

  // --- 5. 辅助任务：精确控制时序 ---
  // 关键策略：在下降沿操作信号，确保上升沿采样稳定
  task wait_w_clk_neg;
    @(negedge w_clk);
  endtask

  task wait_r_clk_neg;
    @(negedge r_clk);
  endtask

  // 等待上升沿（用于观察）
  task wait_r_clk_pos;
    @(posedge r_clk);
  endtask

  // --- 6. 测试主流程 ---
  initial begin
    // 波形输出配置
    // 兼容 Makefile 中的 +define+fsdb
`ifdef fsdb
    $fsdbDumpfile(
        "/home/jay/Desktop/graduation_project/practise/fifo/asyn_fifo/testbench.fsdb");  // 明确指定后缀，防止自动添加
    $fsdbDumpvars("+all");
`endif

    // 兼容通用的 VCD 输出
    $dumpfile("fifo_wave.vcd");
    $dumpvars(0, tb_fifo);

    // 初始化
    rst   = 1;
    wen   = 0;
    ren   = 0;
    wdata = 0;

    // 复位序列
    #50;
    rst = 0;  // 释放复位
    #50;

    $display("=== Simulation Start ===");

    // ================================================
    // [TEST 1] 写入数据直到满 (Write until Full)
    // ================================================
    $display("[TEST 1] Writing data 0 to 15...");

    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
      // 1. 等待下降沿，准备驱动
      wait_w_clk_neg();

      // 2. 检查满信号 (Full信号是在写时钟域更新的，所以可以直接用)
      if (!full) begin
        wen   = 1;
        wdata = i;  // 写入 0, 1, 2...

        // 3. 【关键修复】保持信号直到下一个下降沿
        // 这样 wen 会像一个方框一样包住 posedge，绝对会被采到
        wait_w_clk_neg();

        wen   = 0;
        wdata = 0;
      end else begin
        $display("Warning: FIFO Full at %0d, skipping write", i);
        // 如果满了，也要消耗时间等待，避免死循环太快
        wait_w_clk_neg();
      end
    end

    // 等待一段时间，让写指针同步到读时钟域 (Empty 变 0)
    #200;

    // 简单的状态检查
    if (full) $display("SUCCESS: FIFO is Full properly.");
    else $display("ERROR: FIFO should be Full.");

    // ================================================
    // [TEST 2] 读取数据直到空 (Read until Empty)
    // ================================================
    $display("[TEST 2] Reading back data...");

    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
      // 1. 异步等待 FIFO 非空
      // 注意：empty 变低可能有延迟
      while (empty) begin
        wait_r_clk_neg();
      end

      // 2. 发起读操作 (在下降沿拉高)
      wait_r_clk_neg();
      ren = 1;

      // 3. 【关键修复】保持有效直到下一个下降沿
      wait_r_clk_neg();
      ren = 0;

      // 4. 等待数据输出
      // RAM 行为：posedge r_clk 采样 ren -> 数据在 Tco 后输出
      // 因为我们刚刚经过了一个 negedge，离数据出来还有半个周期 + Tco
      // 为了稳妥，我们等待下一个上升沿来观察数据
      wait_r_clk_pos();
      #1;  // 微小延迟，模拟真实采样

      // 5. 数据比对
      expected_data = i;
      if (rdata === expected_data) begin
        $display("Read OK: Addr=%0d, Data=%0d (Time: %0t)", i, rdata, $time);
      end else begin
        $display("Read ERROR: Expected %0d, Got %0d (Time: %0t)", expected_data, rdata, $time);
      end
    end

    // 等待状态更新
    #200;

    if (empty) $display("SUCCESS: FIFO is Empty properly.");
    else $display("ERROR: FIFO should be Empty.");

    $display("=== Simulation End ===");
    $finish;
  end

endmodule
