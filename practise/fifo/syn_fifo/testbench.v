`timescale 1ns / 1ps

module testbench ();

  // --- 参数定义 ---
  parameter DATA_BIT_WIDTH = 8;
  parameter DATA_DEPTH = 16;
  parameter DATA_DEPTH_WIDTH = 4;

  // --- 信号声明 ---
  reg                          clk;
  reg                          rst;
  reg                          wen;
  reg     [DATA_BIT_WIDTH-1:0] wdata;
  reg                          ren;

  wire    [DATA_BIT_WIDTH-1:0] rdata;
  wire                         full;
  wire                         empty;

  // 用于验证数据的临时变量
  integer                      i;

  // --- 实例化待测模块 (DUT) ---
  fifo #(
      .DATA_BIT_WIDTH  (DATA_BIT_WIDTH),
      .DATA_DEPTH_WIDTH(DATA_DEPTH_WIDTH)
  ) u_fifo (
      .clk  (clk),
      .rst  (rst),
      .wen  (wen),
      .wdata(wdata),
      .ren  (ren),
      .rdata(rdata),
      .full (full),
      .empty(empty)
  );

  // --- 时钟生成 (周期 10ns) ---
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // --- 测试任务定义 (让主流程更清晰) ---

  // 任务：写入一个数据
  task write_word(input [DATA_BIT_WIDTH-1:0] data_in);
    begin
      @(posedge clk);  // 等待时钟上升沿
      wen   <= 1;
      wdata <= data_in;
      @(posedge clk);  // 保持一拍
      wen <= 0;
      // 可选：稍微延迟一点打印，为了观察方便
      #1 $display("[Time %0t] Write: %h | Full: %b", $time, data_in, full);
    end
  endtask

  // 任务：读取一个数据
  // 注意：Standard Mode 下，Ren 拉高后，下一拍数据才有效
  task read_word();
    begin
      @(posedge clk);
      ren <= 1;
      @(posedge clk);  // 命令被采样的时刻
      ren <= 0;
      // 此时 RAM 刚刚把数据输出，等待下一个时钟沿或稍微延时后采样
      #1 $display("[Time %0t] Read : %h | Empty: %b", $time, rdata, empty);
    end
  endtask

  // --- 主测试流程 ---
  initial begin
    // 1. 初始化
    $display("=== Simulation Start ===");
    rst   = 1;
    wen   = 0;
    ren   = 0;
    wdata = 0;

    #20;
    rst = 0;  // 释放复位
    $display("=== Reset Release ===");
    #10;

    // 2. 写入测试：写入 4 个数据
    $display("\n--- Test 1: Basic Write ---");
    write_word(8'hAA);
    write_word(8'hBB);
    write_word(8'hCC);
    write_word(8'hDD);

    // 3. 读取测试：读取 4 个数据
    $display("\n--- Test 2: Basic Read ---");
    // 注意：因为是 Standard Mode，Ren 拉高后的下一拍数据才出来
    read_word();  // Expect AA
    read_word();  // Expect BB
    read_word();  // Expect CC
    read_word();  // Expect DD

    // 4. 满标志测试：填满 FIFO (深度16)
    $display("\n--- Test 3: Fill FIFO & Check FULL ---");
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
      write_word(i);  // 写入 0x00 到 0x0F
    end

    #1;
    if (full) $display(">>> SUCCESS: FIFO is FULL as expected.");
    else $display(">>> FAILURE: FIFO should be FULL but is not.");

    // 5. 溢出保护测试
    $display("\n--- Test 4: Write to Full FIFO (Overflow Protection) ---");
    write_word(8'hFF);  // 尝试写入 FF，应该被忽略
    // 这里的 w_ptr 应该保持不变，下次读出来的应该是 0x00 而不是 0xFF

    // 6. 清空测试
    $display("\n--- Test 5: Empty FIFO & Check EMPTY ---");
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
      read_word();  // 应该读出 0x00 到 0x0F
    end

    #1;
    if (empty) $display(">>> SUCCESS: FIFO is EMPTY as expected.");
    else $display(">>> FAILURE: FIFO should be EMPTY but is not.");

    // 7. 下溢保护测试
    $display("\n--- Test 6: Read from Empty FIFO (Underflow Protection) ---");
    read_word();  // 应该读出旧数据或无效数据，但 r_ptr 不应改变

    // 8. 结束
    #20;
    $display("\n=== Simulation End ===");
    $finish;
  end

  // --- 波形输出 (如果你用 GTKWave 或 Vivado 仿真) ---
  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/practise/fifo/syn_fifo/testbench.fsdb");
    $fsdbDumpvars("+all");
  end


endmodule
