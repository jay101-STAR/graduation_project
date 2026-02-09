`timescale 1ns / 1ps

module tb_div;

  // ==========================================
  // 1. 信号定义
  // ==========================================
  reg clk;
  reg rst;
  reg div_sign;  // 控制信号：0=无符号，1=有符号
  reg div_start;
  reg [31:0] dividend;
  reg [31:0] divisor;

  wire [31:0] div_result_q;
  wire [31:0] div_result_r;
  wire div_done;
  wire div_busy;

  // 测试统计
  integer pass_count;
  integer fail_count;
  integer test_count;

  // ==========================================
  // 2. 实例化待测模块 (DUT)
  // ==========================================
  div u_div (
      .clk         (clk),
      .rst         (rst),
      .div_sign    (div_sign),      // 连接符号控制位
      .div_start   (div_start),
      .dividend    (dividend),
      .divisor     (divisor),
      .div_result_q(div_result_q),
      .div_result_r(div_result_r),
      .div_done    (div_done),
      .div_busy    (div_busy)
  );

  // ==========================================
  // 3. 时钟生成 (100MHz)
  // ==========================================
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // ==========================================
  // 4. 自动测试任务 (Task)
  // ==========================================
  task test_case;
    input mode;  // 0: Unsigned, 1: Signed
    input [31:0] a;  // 被除数
    input [31:0] b;  // 除数
    input check_zero;  // 1: 检查除零, 0: 跳过除零检查

    reg [31:0] exp_q;  // 预期商
    reg [31:0] exp_r;  // 预期余数
    reg is_exception;  // 标记是否为异常情况
    begin
      test_count   = test_count + 1;
      is_exception = 0;

      // 1. 设置输入信号
      div_sign     = mode;
      dividend     = a;
      divisor      = b;

      // 2. 发送 Start 脉冲
      @(posedge clk) div_start = 1;
      @(posedge clk) div_start = 0;

      // 3. 计算预期结果 (Golden Model)
      // 检查除零 (优先级最高)
      if (b == 0) begin
        is_exception = 1;
        // 硬件行为: 商=-1(0xFFFFFFFF), 余数=原始被除数
        exp_q        = 32'hFFFFFFFF;  // -1
        exp_r        = a;  // 原始被除数
        if (check_zero) begin
          $display("[INFO] Test %0d: Division by zero (mode=%0d, a=%h), expecting Q=-1, R=dividend",
                   test_count, mode, a);
        end
      end  // 检查有符号溢出 (-2147483648 / -1)
      else if (mode == 1 && a == 32'h80000000 && b == 32'hFFFFFFFF) begin
        is_exception = 1;
        // 硬件行为: 商=0x80000000, 余数=0
        exp_q        = 32'h80000000;
        exp_r        = 32'b0;
        $display(
            "[INFO] Test %0d: Overflow detected (-2147483648 / -1), expecting Q=0x80000000, R=0",
            test_count);
      end  // 正常计算
      else if (mode == 1) begin
        exp_q = $signed(a) / $signed(b);
        exp_r = $signed(a) % $signed(b);
      end else begin
        exp_q = a / b;
        exp_r = a % b;
      end

      // 4. 等待完成
      wait (div_done);
      @(posedge clk);  // 等待数据稳定

      // 5. 自动比对
      if (div_result_q !== exp_q || div_result_r !== exp_r) begin
        fail_count = fail_count + 1;
        $display("\n[ERROR] Test %0d FAILED at %t", test_count, $time);
        if (mode) begin
          $display("  Mode: SIGNED");
          $display("  Input: %0d / %0d (0x%h / 0x%h)", $signed(a), $signed(b), a, b);
          if (is_exception) $display("  Exception: YES");
          $display("  Expected: Q = %0d (0x%h), R = %0d (0x%h)", $signed(exp_q), exp_q,
                   $signed(exp_r), exp_r);
          $display("  Got:      Q = %0d (0x%h), R = %0d (0x%h)", $signed(div_result_q),
                   div_result_q, $signed(div_result_r), div_result_r);
        end else begin
          $display("  Mode: UNSIGNED");
          $display("  Input: %0d / %0d (0x%h / 0x%h)", a, b, a, b);
          if (is_exception) $display("  Exception: DIV_BY_ZERO");
          $display("  Expected: Q = %0d (0x%h), R = %0d (0x%h)", exp_q, exp_q, exp_r, exp_r);
          $display("  Got:      Q = %0d (0x%h), R = %0d (0x%h)", div_result_q, div_result_q,
                   div_result_r, div_result_r);
        end
      end else begin
        pass_count = pass_count + 1;
        // 通过测试打印
        if (is_exception) begin
          if (b == 0)
            $display(
                "[PASS] Test %0d (DivByZero): %0d / 0 -> Q=-1, R=%0d",
                test_count,
                $signed(
                    a
                ),
                $signed(
                    a
                )
            );
          else
            $display(
                "[PASS] Test %0d (Overflow):  -2147483648 / -1 -> Q=0x%h, R=%0d",
                test_count,
                div_result_q,
                div_result_r
            );
        end else if (mode) begin
          $display("[PASS] Test %0d (Signed):   %0d / %0d = %0d ... %0d", test_count, $signed(a),
                   $signed(b), $signed(div_result_q), $signed(div_result_r));
        end else begin
          $display("[PASS] Test %0d (Unsigned): %0d / %0d = %0d ... %0d", test_count, a, b,
                   div_result_q, div_result_r);
        end
      end

      #20;  // 间隔
    end
  endtask

  // ==========================================
  // 5. 主测试流程
  // ==========================================
  initial begin
    // 初始化
    rst        = 1;
    div_start  = 0;
    div_sign   = 0;
    dividend   = 0;
    divisor    = 0;
    pass_count = 0;
    fail_count = 0;
    test_count = 0;

    #20 rst = 0;
    #20;

    $display("==============================================");
    $display("===          Divider Test Suite            ===");
    $display("==============================================");

    // ------------------------------------------------
    // Group 1: 基础无符号测试
    // ------------------------------------------------
    $display("\n--- Group 1: Basic Unsigned Tests ---");
    test_case(0, 100, 10, 1);
    test_case(0, 7, 3, 1);
    test_case(0, 1, 1, 1);
    test_case(0, 0, 1, 1);
    test_case(0, 5, 1, 1);
    test_case(0, 1024, 32, 1);

    // ------------------------------------------------
    // Group 2: 大数无符号测试
    // ------------------------------------------------
    $display("\n--- Group 2: Large Number Unsigned Tests ---");
    test_case(0, 32'hFFFF_FFFE, 2, 1);  // 大数除以2
    test_case(0, 32'hFFFF_FFFF, 1, 1);  // 最大无符号数除以1
    test_case(0, 32'h8000_0000, 2, 1);  // 大数除以2
    test_case(0, 32'h1234_5678, 32'h9, 1);
    test_case(0, 32'hAAAA_AAAA, 32'h5555_5555, 1);

    // ------------------------------------------------
    // Group 3: 除零测试 (扩展)
    // 硬件行为: Q=-1(0xFFFFFFFF), R=原始被除数
    // ------------------------------------------------
    $display("\n--- Group 3: Division by Zero Tests ---");
    // 无符号除零
    test_case(0, 100, 0, 1);
    test_case(0, 0, 0, 1);
    test_case(0, 32'hFFFFFFFF, 0, 1);  // 最大无符号数/0
    test_case(0, 32'h80000000, 0, 1);  // 大数/0
    // 有符号除零 - 正数
    test_case(1, 100, 0, 1);
    test_case(1, 1, 0, 1);
    test_case(1, 32'h7FFFFFFF, 0, 1);  // 最大正数/0
    // 有符号除零 - 负数
    test_case(1, -100, 0, 1);
    test_case(1, -1, 0, 1);
    test_case(1, 32'h80000000, 0, 1);  // 最小负数/0
    test_case(1, 0, 0, 1);

    // ------------------------------------------------
    // Group 4: 基础有符号测试
    // ------------------------------------------------
    $display("\n--- Group 4: Basic Signed Tests ---");
    test_case(1, 100, 10, 1);  // 正 / 正
    test_case(1, 10, -3, 1);  // 正 / 负
    test_case(1, -10, 3, 1);  // 负 / 正
    test_case(1, -10, -3, 1);  // 负 / 负
    test_case(1, 1, 1, 1);  // 1 / 1
    test_case(1, -1, 1, 1);  // -1 / 1
    test_case(1, 1, -1, 1);  // 1 / -1
    test_case(1, -1, -1, 1);  // -1 / -1

    // ------------------------------------------------
    // Group 5: 有符号边界测试
    // ------------------------------------------------
    $display("\n--- Group 5: Signed Boundary Tests ---");
    test_case(1, 32'h7FFF_FFFF, 1, 1);  // 最大正数 / 1 = 2147483647
    test_case(1, 32'h7FFF_FFFF, -1, 1);  // 最大正数 / -1 = -2147483647
    test_case(1, 32'h8000_0000, 1, 1);  // 最小负数 / 1 = -2147483648
    test_case(1, 32'h8000_0000, 2, 1);  // 最小负数 / 2 = -1073741824
    test_case(1, 32'h8000_0000, -2, 1);  // 最小负数 / -2 = 1073741824
    test_case(1, 32'h8000_0000, 32'h7FFF_FFFF, 1);  // 最小负数 / 最大正数
    test_case(1, 32'h7FFF_FFFF, 32'h8000_0000, 1);  // 最大正数 / 最小负数

    // ------------------------------------------------
    // Group 6: 溢出和特殊边界测试
    // 硬件行为 (溢出): Q=0x80000000, R=0
    // ------------------------------------------------
    $display("\n--- Group 6: Overflow & Special Edge Cases ---");
    // 溢出测试: -2147483648 / -1
    test_case(1, 32'h8000_0000, 32'hFFFF_FFFF, 1);
    // 其他边界
    test_case(1, 0, -1, 1);
    test_case(1, 0, 32'h8000_0000, 1);
    test_case(1, 32'hFFFF_FFFF, 32'hFFFF_FFFF, 1);  // -1 / -1 = 1
    test_case(1, 32'hFFFF_FFFF, 1, 1);  // -1 / 1 = -1
    // 边界组合
    test_case(1, 32'h8000_0000, 32'h8000_0000, 1);  // 最小负数/自身 = 1

    // ------------------------------------------------
    // Group 7: 幂次测试（除数为2的幂）
    // ------------------------------------------------
    $display("\n--- Group 7: Power of 2 Tests ---");
    test_case(0, 32'h1234_5678, 2, 1);
    test_case(0, 32'h1234_5678, 4, 1);
    test_case(0, 32'h1234_5678, 8, 1);
    test_case(0, 32'h1234_5678, 16, 1);
    test_case(0, 32'h1234_5678, 256, 1);
    test_case(0, 32'h1234_5678, 1024, 1);
    test_case(0, 32'hFFFF_FFFF, 2, 1);
    test_case(0, 32'hFFFF_FFFF, 4, 1);

    // ------------------------------------------------
    // Group 8: 余数边界测试
    // ------------------------------------------------
    $display("\n--- Group 8: Remainder Boundary Tests ---");
    test_case(0, 10, 3, 1);  // 余数 = 1
    test_case(0, 11, 3, 1);  // 余数 = 2
    test_case(0, 17, 5, 1);  // 余数 = 2
    test_case(0, 19, 5, 1);  // 余数 = 4 (最大余数)
    test_case(0, 100, 7, 1);  // 余数 = 2
    test_case(1, -10, 3, 1);  // 有符号余数 = -1
    test_case(1, -10, -3, 1);  // 有符号余数 = -1
    test_case(1, 10, -3, 1);  // 有符号余数 = 1

    // ------------------------------------------------
    // Group 9: 交替位模式测试
    // ------------------------------------------------
    $display("\n--- Group 9: Alternating Bit Pattern Tests ---");
    test_case(0, 32'hAAAA_AAAA, 32'h5555_5555, 1);
    test_case(0, 32'h5555_5555, 32'hAAAA_AAAA, 1);
    test_case(0, 32'hFFFF_0000, 32'h0000_FFFF, 1);
    test_case(0, 32'h0000_FFFF, 32'hFFFF_0000, 1);
    test_case(0, 32'hFF00_FF00, 32'h00FF_00FF, 1);
    test_case(1, 32'hAAAA_AAAA, 32'h5555_5555, 1);

    // ------------------------------------------------
    // Group 10: 随机无符号测试
    // ------------------------------------------------
    $display("\n--- Group 10: Random Unsigned Tests (50 cases) ---");
    repeat (50) begin
      test_case(0, $random, ($random & 32'h7FFFFFFF) + 1, 1);
    end

    // ------------------------------------------------
    // Group 11: 随机有符号测试
    // ------------------------------------------------
    $display("\n--- Group 11: Random Signed Tests (50 cases) ---");
    repeat (50) begin
      test_case(1, $random, ($random & 32'h7FFFFFFF) | 1, 1);
    end

    // ------------------------------------------------
    // Group 12: 随机混合测试（随机符号）
    // ------------------------------------------------
    $display("\n--- Group 12: Random Mixed Tests (100 cases) ---");
    repeat (100) begin
      test_case({$random} % 2, $random, ($random & 32'h7FFFFFFF) + 1, 1);
    end

    // ------------------------------------------------
    // Group 13: 压力测试（大数值范围）
    // ------------------------------------------------
    $display("\n--- Group 13: Stress Tests ---");
    test_case(0, 32'hFFFF_FFFF, 32'hFFFF_FFFF, 1);
    test_case(0, 32'hFFFF_FFFF, 32'h7FFF_FFFF, 1);
    test_case(0, 32'h8000_0000, 32'hFFFF_FFFF, 1);
    test_case(0, 32'h8000_0000, 32'h8000_0000, 1);
    test_case(0, 32'h1234_5678, 32'h9ABCDEF0, 1);
    test_case(0, 32'h1111_1111, 32'h1111_1111, 1);
    test_case(0, 32'h2222_2222, 32'h1111_1111, 1);

    // ------------------------------------------------
    // Group 14: 连续相同测试
    // ------------------------------------------------
    $display("\n--- Group 14: Sequential Tests ---");
    test_case(0, 100, 7, 1);
    test_case(0, 101, 7, 1);
    test_case(0, 102, 7, 1);
    test_case(0, 103, 7, 1);
    test_case(0, 104, 7, 1);
    test_case(0, 105, 7, 1);
    test_case(0, 106, 7, 1);
    test_case(0, 107, 7, 1);

    // ------------------------------------------------
    // Group 15: 极端边界值测试 - 全0和全1模式
    // ------------------------------------------------
    $display("\n--- Group 15: Extreme All-0s and All-1s Patterns ---");
    test_case(0, 32'h00000000, 32'hFFFFFFFF, 1);  // 0 / 最大无符号数
    test_case(0, 32'hFFFFFFFF, 32'h00000001, 1);  // 最大无符号数 / 1
    test_case(1, 32'h00000000, 32'hFFFFFFFF, 1);  // 0 / -1
    test_case(1, 32'hFFFFFFFF, 32'h00000001, 1);  // -1 / 1
    test_case(1, 32'hFFFFFFFF, 32'hFFFFFFFF, 1);  // -1 / -1
    test_case(0, 32'h55555555, 32'hAAAAAAAA, 1);  // 交替位
    test_case(0, 32'hAAAAAAAA, 32'h55555555, 1);  // 反向交替位
    test_case(1, 32'h55555555, 32'hAAAAAAAA, 1);  // 有符号交替位
    test_case(1, 32'hAAAAAAAA, 32'h55555555, 1);  // 有符号反向交替位

    // ------------------------------------------------
    // Group 16: 高位/低位边界测试
    // ------------------------------------------------
    $display("\n--- Group 16: High/Low Bits Boundary Tests ---");
    test_case(0, 32'h0000FFFF, 32'h000000FF, 1);  // 低16位 / 低8位
    test_case(0, 32'hFFFF0000, 32'h0000FF00, 1);  // 高16位 / 中8位
    test_case(0, 32'h00FF00FF, 32'h0000FF00, 1);  // 分散位
    test_case(0, 32'hFF00FF00, 32'h00FF0000, 1);  // 反向分散位
    test_case(0, 32'h00000001, 32'hFFFFFFFF, 1);  // 最小值 / 最大值
    test_case(0, 32'h00000001, 32'h80000000, 1);  // 1 / 0x80000000
    test_case(1, 32'h00000001, 32'h80000000, 1);  // 1 / 最小负数
    test_case(1, 32'h40000000, 32'h20000000, 1);  // 大正数 / 大正数
    test_case(1, 32'hC0000000, 32'h20000000, 1);  // 负数 / 大正数

    // ------------------------------------------------
    // Group 17: 接近除数的边界值
    // ------------------------------------------------
    $display("\n--- Group 17: Near-Divisor Boundary Tests ---");
    test_case(0, 31, 32, 1);   // 比除数小1
    test_case(0, 32, 32, 1);   // 等于除数
    test_case(0, 33, 32, 1);   // 比除数大1
    test_case(0, 63, 32, 1);   // 2*除数-1
    test_case(0, 64, 32, 1);   // 2*除数
    test_case(0, 65, 32, 1);   // 2*除数+1
    test_case(1, -31, 32, 1);  // 负数接近除数
    test_case(1, -32, 32, 1);  // 负数等于除数
    test_case(1, -33, 32, 1);  // 负数超出除数
    test_case(0, 32'hFFFFFFFE, 32'hFFFFFFFF, 1);  // 最大-1 / 最大
    test_case(0, 32'hFFFFFFFD, 32'hFFFFFFFF, 1);  // 最大-2 / 最大

    // ------------------------------------------------
    // Group 18: 特殊算术组合测试
    // ------------------------------------------------
    $display("\n--- Group 18: Special Arithmetic Patterns ---");
    test_case(0, 32'h00000003, 32'h00000002, 1);  // 3/2 = 1...1
    test_case(0, 32'h00000007, 32'h00000003, 1);  // 7/3 = 2...1
    test_case(0, 32'h0000000F, 32'h00000004, 1);  // 15/4 = 3...3
    test_case(0, 32'h0000001F, 32'h00000005, 1);  // 31/5 = 6...1
    test_case(0, 32'h000003FF, 32'h00000020, 1);  // 1023/32 = 31...31
    test_case(0, 32'h0000FFFF, 32'h00000100, 1);  // 65535/256 = 255...255
    test_case(1, -3, 2, 1);   // -3/2
    test_case(1, -7, 3, 1);   // -7/3
    test_case(1, -15, 4, 1);  // -15/4

    // ------------------------------------------------
    // Group 19: 位模式 walk 测试
    // ------------------------------------------------
    $display("\n--- Group 19: Walking Bit Pattern Tests ---");
    test_case(0, 32'h00000001, 32'h00000001, 1);  // bit 0
    test_case(0, 32'h00000002, 32'h00000002, 1);  // bit 1
    test_case(0, 32'h00000004, 32'h00000004, 1);  // bit 2
    test_case(0, 32'h00000008, 32'h00000008, 1);  // bit 3
    test_case(0, 32'h80000000, 32'h80000000, 1);  // bit 31
    test_case(0, 32'h00000001, 32'h80000000, 1);  // min bit / max bit
    test_case(0, 32'h80000000, 32'h00000001, 1);  // max bit / min bit
    test_case(0, 32'h40000000, 32'h00000002, 1);  // bit 30 / bit 1
    test_case(0, 32'h20000000, 32'h00000004, 1);  // bit 29 / bit 2

    // ------------------------------------------------
    // Group 20: 零值相关测试
    // ------------------------------------------------
    $display("\n--- Group 20: Zero-Related Tests ---");
    test_case(0, 0, 1, 1);
    test_case(0, 0, 2, 1);
    test_case(0, 0, 32'h7FFFFFFF, 1);
    test_case(0, 0, 32'h80000000, 1);
    test_case(0, 0, 32'hFFFFFFFF, 1);
    test_case(1, 0, -1, 1);
    test_case(1, 0, -2, 1);
    test_case(1, 0, 32'h7FFFFFFF, 1);
    test_case(1, 0, 32'h80000000, 1);

    // ------------------------------------------------
    // Group 21: 负数除数边界
    // ------------------------------------------------
    $display("\n--- Group 21: Negative Divisor Boundary ---");
    test_case(1, 100, -1, 1);
    test_case(1, 100, -2, 1);
    test_case(1, 100, -128, 1);
    test_case(1, 100, -256, 1);
    test_case(1, 100, -32768, 1);
    test_case(1, 32'h7FFFFFFF, -1, 1);   // 最大正数 / -1
    test_case(1, 32'h7FFFFFFF, -2, 1);   // 最大正数 / -2
    test_case(1, 32'h40000000, -2, 1);   // 大正数 / -2
    test_case(1, -100, -1, 1);
    test_case(1, -100, -2, 1);

    // ------------------------------------------------
    // Group 22: 大规模随机无符号测试 (300个)
    // ------------------------------------------------
    $display("\n--- Group 22: Random Unsigned Tests (300 cases) ---");
    repeat (300) begin
      test_case(0, $random, ($random & 32'h7FFFFFFF) + 1, 1);
    end

    // ------------------------------------------------
    // Group 23: 大规模随机有符号测试 (300个)
    // ------------------------------------------------
    $display("\n--- Group 23: Random Signed Tests (300 cases) ---");
    repeat (300) begin
      test_case(1, $random, ($random & 32'h7FFFFFFF) | 1, 1);
    end

    // ------------------------------------------------
    // Group 24: 大规模随机混合测试 (400个)
    // ------------------------------------------------
    $display("\n--- Group 24: Random Mixed Tests (400 cases) ---");
    repeat (400) begin
      test_case({$random} % 2, $random, ($random & 32'h7FFFFFFF) + 1, 1);
    end

    // ------------------------------------------------
    // Group 25: 更多位模式组合
    // ------------------------------------------------
    $display("\n--- Group 25: Additional Bit Patterns ---");
    test_case(0, 32'h33333333, 32'h11111111, 1);  // 重复0011 / 重复0001
    test_case(0, 32'h66666666, 32'h22222222, 1);  // 重复0110 / 重复0010
    test_case(0, 32'h99999999, 32'h33333333, 1);  // 重复1001 / 重复0011
    test_case(0, 32'hCCCCCCCC, 32'h44444444, 1);  // 重复1100 / 重复0100
    test_case(0, 32'h0F0F0F0F, 32'h03030303, 1);  // 交替00001111
    test_case(0, 32'hF0F0F0F0, 32'h40404040, 1);  // 交替11110000
    test_case(1, 32'h33333333, 32'h11111111, 1);
    test_case(1, 32'hCCCCCCCC, 32'h44444444, 1);

    // ------------------------------------------------
    // Group 26: Fibonacci-like序列测试
    // ------------------------------------------------
    $display("\n--- Group 26: Fibonacci-like Sequence Tests ---");
    test_case(0, 1, 1, 1);
    test_case(0, 2, 1, 1);
    test_case(0, 3, 2, 1);
    test_case(0, 5, 3, 1);
    test_case(0, 8, 5, 1);
    test_case(0, 13, 8, 1);
    test_case(0, 21, 13, 1);
    test_case(0, 34, 21, 1);
    test_case(0, 55, 34, 1);
    test_case(0, 89, 55, 1);
    test_case(0, 144, 89, 1);
    test_case(0, 233, 144, 1);
    test_case(0, 377, 233, 1);
    test_case(0, 610, 377, 1);
    test_case(0, 987, 610, 1);
    test_case(0, 1597, 987, 1);
    test_case(0, 2584, 1597, 1);
    test_case(0, 4181, 2584, 1);
    test_case(0, 6765, 4181, 1);
    test_case(0, 10946, 6765, 1);

    // ------------------------------------------------
    // Group 27: 连续整数序列测试 (长序列)
    // ------------------------------------------------
    $display("\n--- Group 27: Long Sequential Tests ---");
    begin : seq_test
      integer i;
      for (i = 1; i <= 100; i = i + 1) begin
        test_case(0, i * 100, 7, 1);
      end
    end

    // ------------------------------------------------
    // Group 28: 2的幂次范围测试
    // ------------------------------------------------
    $display("\n--- Group 28: Power of 2 Range Tests ---");
    test_case(0, 32'h00000001, 32'h00000001, 1);  // 2^0
    test_case(0, 32'h00000002, 32'h00000002, 1);  // 2^1
    test_case(0, 32'h00000004, 32'h00000004, 1);  // 2^2
    test_case(0, 32'h00000008, 32'h00000008, 1);  // 2^3
    test_case(0, 32'h00000010, 32'h00000010, 1);  // 2^4
    test_case(0, 32'h00000020, 32'h00000020, 1);  // 2^5
    test_case(0, 32'h00000040, 32'h00000040, 1);  // 2^6
    test_case(0, 32'h00000080, 32'h00000080, 1);  // 2^7
    test_case(0, 32'h00000100, 32'h00000100, 1);  // 2^8
    test_case(0, 32'h00000200, 32'h00000200, 1);  // 2^9
    test_case(0, 32'h00000400, 32'h00000400, 1);  // 2^10
    test_case(0, 32'h00000800, 32'h00000800, 1);  // 2^11
    test_case(0, 32'h00001000, 32'h00001000, 1);  // 2^12
    test_case(0, 32'h00002000, 32'h00002000, 1);  // 2^13
    test_case(0, 32'h00004000, 32'h00004000, 1);  // 2^14
    test_case(0, 32'h00008000, 32'h00008000, 1);  // 2^15
    test_case(0, 32'h00010000, 32'h00010000, 1);  // 2^16
    test_case(0, 32'h00020000, 32'h00020000, 1);  // 2^17
    test_case(0, 32'h00040000, 32'h00040000, 1);  // 2^18
    test_case(0, 32'h00080000, 32'h00080000, 1);  // 2^19
    test_case(0, 32'h00100000, 32'h00100000, 1);  // 2^20
    test_case(0, 32'h00200000, 32'h00200000, 1);  // 2^21
    test_case(0, 32'h00400000, 32'h00400000, 1);  // 2^22
    test_case(0, 32'h00800000, 32'h00800000, 1);  // 2^23
    test_case(0, 32'h01000000, 32'h01000000, 1);  // 2^24
    test_case(0, 32'h02000000, 32'h02000000, 1);  // 2^25
    test_case(0, 32'h04000000, 32'h04000000, 1);  // 2^26
    test_case(0, 32'h08000000, 32'h08000000, 1);  // 2^27
    test_case(0, 32'h10000000, 32'h10000000, 1);  // 2^28
    test_case(0, 32'h20000000, 32'h20000000, 1);  // 2^29
    test_case(0, 32'h40000000, 32'h40000000, 1);  // 2^30
    test_case(0, 32'h80000000, 32'h80000000, 1);  // 2^31

    // ------------------------------------------------
    // Group 29: 256的倍数测试
    // ------------------------------------------------
    $display("\n--- Group 29: Multiples of 256 Tests ---");
    begin : mult256_test
      integer i;
      for (i = 0; i < 64; i = i + 1) begin
        test_case(0, i * 256, 256, 1);
      end
    end

    // ------------------------------------------------
    // Group 30: 质数相关测试
    // ------------------------------------------------
    $display("\n--- Group 30: Prime Number Related Tests ---");
    test_case(0, 97, 2, 1);     // 质数 / 2
    test_case(0, 997, 3, 1);    // 质数 / 3
    test_case(0, 999983, 7, 1); // 大质数 / 7
    test_case(0, 2147483647, 13, 1); // 梅森素数 / 13
    test_case(0, 65537, 257, 1);     // 费马素数
    test_case(1, 97, -2, 1);
    test_case(1, -997, 3, 1);
    test_case(1, -999983, -7, 1);

    // ------------------------------------------------
    // Group 31: 极大除数测试
    // ------------------------------------------------
    $display("\n--- Group 31: Very Large Divisor Tests ---");
    test_case(0, 100, 32'h7FFFFFFF, 1);      // 小 / 大
    test_case(0, 1000, 32'hFFFFFFFF, 1);     // 小 / 最大
    test_case(0, 1, 32'h80000000, 1);        // 1 / 大
    test_case(0, 32'h0000FFFF, 32'hFFFF0000, 1);  // 中 / 大
    test_case(1, 100, 32'h7FFFFFFF, 1);      // 有符号小 / 大正数
    test_case(1, 100, 32'h80000000, 1);      // 有符号小 / 大负数
    test_case(1, -100, 32'h7FFFFFFF, 1);     // 有符号负 / 大正数
    test_case(1, -100, 32'h80000000, 1);     // 有符号负 / 大负数

    // ------------------------------------------------
    // Group 32: 回文模式测试
    // ------------------------------------------------
    $display("\n--- Group 32: Palindrome Pattern Tests ---");
    test_case(0, 32'h01100110, 32'h00010001, 1);
    test_case(0, 32'h12211221, 32'h00110011, 1);
    test_case(0, 32'h34433443, 32'h01010101, 1);
    test_case(0, 32'h78877887, 32'h01110111, 1);
    test_case(0, 32'h9FF99FF9, 32'h10011001, 1);
    test_case(1, 32'h01100110, 32'h00010001, 1);
    test_case(1, 32'h9FF99FF9, 32'h10011001, 1);

    // ------------------------------------------------
    // Group 33: 硬件测试向量 (数千个随机测试)
    // ------------------------------------------------
    $display("\n--- Group 33: Massive Random Unsigned (2000 cases) ---");
    repeat (2000) begin
      test_case(0, $random, ($random & 32'h7FFFFFFF) + 1, 1);
    end

    // ------------------------------------------------
    // Group 34: 大规模有符号随机测试 (2000 cases)
    // ------------------------------------------------
    $display("\n--- Group 34: Massive Random Signed (2000 cases) ---");
    repeat (2000) begin
      test_case(1, $random, ($random & 32'h7FFFFFFF) | 1, 1);
    end

    // ------------------------------------------------
    // Group 35: 超大规模混合随机测试 (5000 cases)
    // ------------------------------------------------
    $display("\n--- Group 35: Ultra Massive Mixed Random (5000 cases) ---");
    repeat (5000) begin
      test_case({$random} % 2, $random, ($random & 32'h7FFFFFFF) + 1, 1);
    end

    // ==========================================
    // 测试完成报告
    // ==========================================
    $display("\n==============================================");
    $display("===          Test Summary                  ===");
    $display("==============================================");
    $display("  Total Tests:  %0d", test_count);
    $display("  Passed:       %0d", pass_count);
    $display("  Failed:       %0d", fail_count);
    $display("  Pass Rate:    %0d%%", (pass_count * 100) / test_count);
    $display("==============================================");

    if (fail_count == 0) begin
      $display("===        ALL TESTS PASSED!               ===");
    end else begin
      $display("===     SOME TESTS FAILED!                 ===");
    end
    $display("==============================================");

    $finish;
  end

  // 波形输出
  initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars("+all");
  end

endmodule
