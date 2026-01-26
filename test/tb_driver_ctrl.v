`timescale 1ns / 1ns

module tb_driver_ctrl;

  // ==========================================
  // 1. 信号定义
  // ==========================================
  // 系统信号
  reg         mclk;  // MCLK, 100MHz
  reg         rst_n;

  // 用户接口信号 (User Interface)
  reg         req;  // 请求信号
  reg         rw_type;  // 0: Write, 1: Read
  reg  [15:0] addr_in;  // 输入地址
  reg  [15:0] data_wr;  // 输入写数据
  wire [15:0] data_rd;  // 输出读数据
  wire        busy;
  wire        done;

  // 物理接口信号 (Physical Interface to Chip)
  wire        CS_AS;  // Address Strobe
  wire        CS_RW_B;  // Read/Write#
  wire [15:0] CS_AD;  // Bidirectional Bus

  // ==========================================
  // 2. 时钟生成 (100MHz MCLK)
  // ==========================================
  // 周期 = 10ns, 半周期 = 5ns
  initial begin
    mclk = 0;
    forever #5 mclk = ~mclk;
  end

  // ==========================================
  // 3. 实例化设计模块 (DUT)
  // ==========================================
  driver_ctrl u_dut (
      .mclk   (mclk),
      .rst_n  (rst_n),
      .req    (req),
      .rw_type(rw_type),
      .addr_in(addr_in),
      .data_wr(data_wr),
      .data_rd(data_rd),
      .busy   (busy),
      .done   (done),
      .CS_AS  (CS_AS),
      .CS_RW_B(CS_RW_B),
      .CS_AD  (CS_AD)
  );

  // ==========================================
  // 4. 虚拟从机模型 (Slave Bus Functional Model)
  //    用于模拟外部芯片，验证读写时序
  // ==========================================
  reg [15:0] slave_addr_reg;  // 从机锁存的地址
  reg        slave_rw_latch;  // 从机锁存的读写状态
  reg [15:0] slave_data_out;  // 从机准备发送的数据
  reg        slave_drive_enable;  // 从机输出使能 (1=输出, 0=高阻)
  reg [ 3:0] slave_wait_cnt;  // 读延迟计数器

  // 三态门控制：只有在读操作且延迟满足后，从机才驱动总线
  assign CS_AD = (slave_drive_enable) ? slave_data_out : 16'hzzzz;

  always @(posedge mclk) begin
    // --- A. 地址锁存阶段 (CS_AS High) ---
    if (CS_AS) begin
      slave_addr_reg     <= CS_AD;  // 锁存地址
      slave_rw_latch     <= CS_RW_B;  // 锁存读写命令
      slave_wait_cnt     <= 0;  // 重置计数器
      slave_drive_enable <= 0;  // 此时必须释放总线
    end  // --- B. 数据传输阶段 (CS_AS Low) ---
    else begin
      // B1. 写操作处理 (Master -> Slave)
      if (slave_rw_latch == 1'b0) begin
        // 简单起见，我们在 AS 拉低后的时刻采样数据
        // 实际波形中数据在 AS 下降沿后保持
        // 这里只做被动接收，不驱动总线
        slave_drive_enable <= 0;
      end  // B2. 读操作处理 (Slave -> Master)
      else begin
        // 题目时序图：Address -> Turn-around (1 cycle) -> Delay (8 cycles) -> Data
        // 总共等待约 9 个周期后驱动数据
        slave_wait_cnt <= slave_wait_cnt + 1'b1;

        if (slave_wait_cnt == 8) begin
          // 模拟数据准备好
          // 根据地址不同返回不同数据，方便验证
          case (slave_addr_reg)
            16'h00A0: slave_data_out <= 16'hBEEF;  // 测试数据A
            16'h00B0: slave_data_out <= 16'hCAFE;  // 测试数据B
            default:  slave_data_out <= 16'hFFFF;
          endcase
          slave_drive_enable <= 1'b1;  // 开启三态门
          $display("%t [Slave] Driving Data 0x%h to Bus", $time, slave_data_out);
        end  // 读取结束后释放总线 (假设 Master 会在几个周期后停止读)
        else if (slave_wait_cnt > 8) begin
          slave_drive_enable <= 1'b0;
        end
      end
    end
  end

  // ==========================================
  // 5. 测试流程 (Stimulus)
  // ==========================================
  initial begin
    // --- 初始化 ---
    rst_n              = 0;
    req                = 0;
    rw_type            = 0;
    addr_in            = 0;
    data_wr            = 0;
    slave_drive_enable = 0;

    $display("==============================");
    $display(" Simulation Start ");
    $display("==============================");

    // --- 释放复位 ---
    #100;
    rst_n = 1;
    #20;

    // -----------------------------------------------------------
    // 测试用例 1: 写操作 (Write 0x1234 to Address 0x0050)
    // -----------------------------------------------------------
    $display("\n%t [Test 1] Starting WRITE Transaction...", $time);

    req = 1'b1;  // Start
    @(posedge mclk);
    addr_in = 16'h0050;
    data_wr = 16'h1234;
    rw_type = 1'b0;  // Write

    @(posedge mclk);
    req = 1'b0;  // Pulse req

    #9 req = 1'b1;  // Start
    @(posedge mclk);
    addr_in = 16'h0051;
    data_wr = 16'h5678;
    rw_type = 1'b0;  // Write
    @(posedge mclk);
    req = 1'b0;  // Pulse req

    // 等待完成
    #9 req = 1'b1;
    @(posedge mclk);
    addr_in = 16'h00A0;
    rw_type = 1'b1;  // Read

    @(posedge mclk);
    req     = 1'b0;
    rw_type = 1'b0;  // Read

    // 自动检查结果
    if (data_rd === 16'hBEEF)
      $display("%t [Test 2] SUCCESS: Read Data matches expected (0xBEEF).", $time);
    else $display("%t [Test 2] ERROR: Read Data (0x%h) != Expected (0xBEEF).", $time, data_rd);


    #100 #19 req = 1'b1;
    @(posedge mclk);
    addr_in = 16'h0052;
    data_wr = 16'h9abc;
    rw_type = 1'b0;  // Write
    @(posedge mclk);
    req = 1'b0;  // Pulse req


    #2000 $display("\n==============================");
    $display(" Simulation Finished ");
    $display("==============================");
    $finish;
  end


  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/test/tb_driver_ctrl.fsdb");
    $fsdbDumpvars("+all");
  end


endmodule
