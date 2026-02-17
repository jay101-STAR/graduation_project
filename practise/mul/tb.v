`timescale 1ns / 1ps

// ============================================================================
// mul 模块测试平台
// 测试 32位 Booth Radix-4 乘法器的正确性
// 支持：无符号×无符号、有符号×有符号、有符号×无符号
// ============================================================================

module tb;

  // ============================================================================
  // 测试参数
  // ============================================================================
  parameter RANDOM_TESTS = 50;  // 随机测试数量
  parameter CLOCK_PERIOD = 10;  // 时钟周期 (ns)

  // ============================================================================
  // 测试信号
  // ============================================================================
  reg            clk;
  reg     [31:0] mul_a_i;
  reg     [31:0] mul_b_i;
  reg            mul_a_sign;
  reg            mul_b_sign;
  reg            mul_we;
  wire    [63:0] mul_result;

  // 测试统计
  integer        test_count;
  integer        pass_count;
  integer        fail_count;

  // 期望结果
  reg     [63:0] expected_result;
  reg     [63:0] signed_result;
  reg     [63:0] unsigned_result;

  // ============================================================================
  // 实例化被测模块
  // ============================================================================
  mul dut (
      .mul_a_i   (mul_a_i),
      .mul_b_i   (mul_b_i),
      .mul_a_sign(mul_a_sign),
      .mul_b_sign(mul_b_sign),
      .mul_we    (mul_we),
      .mul_result(mul_result)
  );

  // ============================================================================
  // 时钟生成
  // ============================================================================
  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD / 2) clk = ~clk;
  end

  // ============================================================================
  // 测试任务：执行单个测试用例
  // ============================================================================
  task test_multiply;
    input [31:0] a;
    input [31:0] b;
    input a_signed;
    input b_signed;
    input string test_name;
    begin
      test_count = test_count + 1;

      // 设置输入
      mul_a_i    = a;
      mul_b_i    = b;
      mul_a_sign = a_signed;
      mul_b_sign = b_signed;
      mul_we     = 1'b1;

      // 计算期望结果
      if (a_signed && b_signed) begin
        // 有符号 × 有符号
        signed_result   = $signed(a) * $signed(b);
        expected_result = signed_result;
      end else if (a_signed && !b_signed) begin
        // 有符号 × 无符号 (MULHSU)
        signed_result   = $signed(a) * $signed({1'b0, b});
        expected_result = signed_result;
      end else if (!a_signed && b_signed) begin
        // 无符号 × 有符号
        signed_result   = $signed({1'b0, a}) * $signed(b);
        expected_result = signed_result;
      end else begin
        // 无符号 × 无符号
        unsigned_result = a * b;
        expected_result = unsigned_result;
      end

      // 等待组合逻辑稳定
      #(CLOCK_PERIOD);

      // 检查结果
      if (mul_result === expected_result) begin
        pass_count = pass_count + 1;
        $display("[PASS] Test %0d: %s", test_count, test_name);
        $display("       a=0x%h, b=0x%h, a_sign=%b, b_sign=%b", a, b, a_signed, b_signed);
        $display("       result=0x%h (expected=0x%h)", mul_result, expected_result);
      end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Test %0d: %s", test_count, test_name);
        $display("       a=0x%h (%0d), b=0x%h (%0d), a_sign=%b, b_sign=%b", a, $signed(a), b,
                 $signed(b), a_signed, b_signed);
        $display("       result  =0x%h", mul_result);
        $display("       expected=0x%h", expected_result);
        if (a_signed && b_signed) begin
          $display("       signed×signed: %0d * %0d = %0d (expected %0d)", $signed(a),
                   $signed(b), $signed(mul_result), $signed(expected_result));
        end else if (a_signed && !b_signed) begin
          $display("       signed×unsigned: %0d * %0d = %0d (expected %0d)", $signed(a), b,
                   $signed(mul_result), $signed(expected_result));
        end else if (!a_signed && b_signed) begin
          $display("       unsigned×signed: %0d * %0d = %0d (expected %0d)", a, $signed(b),
                   $signed(mul_result), $signed(expected_result));
        end else begin
          $display("       unsigned×unsigned: %0d * %0d = %0d (expected %0d)", a, b, mul_result,
                   expected_result);
        end
      end
      $display("");
    end
  endtask

  // ============================================================================
  // 主测试流程
  // ============================================================================
  initial begin
    // 初始化
    test_count = 0;
    pass_count = 0;
    fail_count = 0;
    mul_a_i    = 0;
    mul_b_i    = 0;
    mul_a_sign = 0;
    mul_b_sign = 0;
    mul_we     = 0;

    $display("============================================================");
    $display("乘法器测试开始");
    $display("测试模块: mul (32-bit Booth Radix-4)");
    $display("支持: 无符号×无符号、有符号×有符号、有符号×无符号");
    $display("============================================================");
    $display("");

    // 等待初始化
    #(CLOCK_PERIOD * 2);

    // ========================================================================
    // 测试组 1: 基本无符号乘法
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 1: 基本无符号乘法");
    $display("------------------------------------------------------------");

    test_multiply(32'd0, 32'd0, 1'b0, 1'b0, "0 * 0");
    test_multiply(32'd1, 32'd1, 1'b0, 1'b0, "1 * 1");
    test_multiply(32'd2, 32'd3, 1'b0, 1'b0, "2 * 3");
    test_multiply(32'd10, 32'd20, 1'b0, 1'b0, "10 * 20");
    test_multiply(32'd100, 32'd100, 1'b0, 1'b0, "100 * 100");
    test_multiply(32'd1000, 32'd1000, 1'b0, 1'b0, "1000 * 1000");

    // ========================================================================
    // 测试组 2: 边界值测试（无符号）
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 2: 边界值测试（无符号）");
    $display("------------------------------------------------------------");

    test_multiply(32'd0, 32'hFFFFFFFF, 1'b0, 1'b0, "0 * MAX_UINT");
    test_multiply(32'hFFFFFFFF, 32'd0, 1'b0, 1'b0, "MAX_UINT * 0");
    test_multiply(32'd1, 32'hFFFFFFFF, 1'b0, 1'b0, "1 * MAX_UINT");
    test_multiply(32'hFFFFFFFF, 32'd1, 1'b0, 1'b0, "MAX_UINT * 1");
    test_multiply(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, 1'b0, "MAX_UINT * MAX_UINT");
    test_multiply(32'h80000000, 32'd2, 1'b0, 1'b0, "2^31 * 2");
    test_multiply(32'h7FFFFFFF, 32'd2, 1'b0, 1'b0, "(2^31-1) * 2");

    // ========================================================================
    // 测试组 3: 基本有符号乘法
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 3: 基本有符号乘法");
    $display("------------------------------------------------------------");

    test_multiply(32'd0, 32'd0, 1'b1, 1'b1, "signed: 0 * 0");
    test_multiply(32'd1, 32'd1, 1'b1, 1'b1, "signed: 1 * 1");
    test_multiply(32'd2, 32'd3, 1'b1, 1'b1, "signed: 2 * 3");
    test_multiply(32'd10, 32'd20, 1'b1, 1'b1, "signed: 10 * 20");
    test_multiply(-32'd1, 32'd1, 1'b1, 1'b1, "signed: -1 * 1");
    test_multiply(32'd1, -32'd1, 1'b1, 1'b1, "signed: 1 * -1");
    test_multiply(-32'd1, -32'd1, 1'b1, 1'b1, "signed: -1 * -1");
    test_multiply(-32'd5, 32'd10, 1'b1, 1'b1, "signed: -5 * 10");
    test_multiply(32'd10, -32'd5, 1'b1, 1'b1, "signed: 10 * -5");
    test_multiply(-32'd10, -32'd5, 1'b1, 1'b1, "signed: -10 * -5");

    // ========================================================================
    // 测试组 4: 有符号边界值
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 4: 有符号边界值");
    $display("------------------------------------------------------------");

    test_multiply(32'h7FFFFFFF, 32'd1, 1'b1, 1'b1, "signed: MAX_INT * 1");
    test_multiply(32'd1, 32'h7FFFFFFF, 1'b1, 1'b1, "signed: 1 * MAX_INT");
    test_multiply(32'h7FFFFFFF, 32'h7FFFFFFF, 1'b1, 1'b1, "signed: MAX_INT * MAX_INT");
    test_multiply(32'h80000000, 32'd1, 1'b1, 1'b1, "signed: MIN_INT * 1");
    test_multiply(32'd1, 32'h80000000, 1'b1, 1'b1, "signed: 1 * MIN_INT");
    test_multiply(32'h80000000, 32'h80000000, 1'b1, 1'b1, "signed: MIN_INT * MIN_INT");
    test_multiply(32'h7FFFFFFF, 32'h80000000, 1'b1, 1'b1, "signed: MAX_INT * MIN_INT");
    test_multiply(32'h80000000, 32'h7FFFFFFF, 1'b1, 1'b1, "signed: MIN_INT * MAX_INT");
    test_multiply(32'h80000000, -32'd1, 1'b1, 1'b1, "signed: MIN_INT * -1");
    test_multiply(-32'd1, 32'h80000000, 1'b1, 1'b1, "signed: -1 * MIN_INT");

    // ========================================================================
    // 测试组 5: 有符号×无符号乘法 (MULHSU) ⭐ 新增
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 5: 有符号×无符号乘法 (MULHSU)");
    $display("------------------------------------------------------------");

    // 基本测试
    test_multiply(32'd1, 32'd1, 1'b1, 1'b0, "MULHSU: 1 * 1");
    test_multiply(32'd10, 32'd20, 1'b1, 1'b0, "MULHSU: 10 * 20");
    test_multiply(-32'd1, 32'd1, 1'b1, 1'b0, "MULHSU: -1 * 1");
    test_multiply(-32'd5, 32'd10, 1'b1, 1'b0, "MULHSU: -5 * 10");
    test_multiply(-32'd10, 32'd100, 1'b1, 1'b0, "MULHSU: -10 * 100");

    // 边界值测试
    test_multiply(32'h7FFFFFFF, 32'hFFFFFFFF, 1'b1, 1'b0, "MULHSU: MAX_INT * MAX_UINT");
    test_multiply(32'h80000000, 32'hFFFFFFFF, 1'b1, 1'b0, "MULHSU: MIN_INT * MAX_UINT");
    test_multiply(-32'd1, 32'hFFFFFFFF, 1'b1, 1'b0, "MULHSU: -1 * MAX_UINT");
    test_multiply(32'h7FFFFFFF, 32'd1, 1'b1, 1'b0, "MULHSU: MAX_INT * 1");
    test_multiply(32'h80000000, 32'd1, 1'b1, 1'b0, "MULHSU: MIN_INT * 1");

    // 特殊模式
    test_multiply(-32'd2, 32'h80000000, 1'b1, 1'b0, "MULHSU: -2 * 2^31");
    test_multiply(-32'd100, 32'h12345678, 1'b1, 1'b0, "MULHSU: -100 * 0x12345678");

    // ========================================================================
    // 测试组 6: 位模式测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 6: 位模式测试");
    $display("------------------------------------------------------------");

    test_multiply(32'hAAAAAAAA, 32'h55555555, 1'b0, 1'b0, "unsigned: 0xAAAAAAAA * 0x55555555");
    test_multiply(32'h55555555, 32'hAAAAAAAA, 1'b0, 1'b0, "unsigned: 0x55555555 * 0xAAAAAAAA");
    test_multiply(32'hAAAAAAAA, 32'h55555555, 1'b1, 1'b1, "signed: 0xAAAAAAAA * 0x55555555");
    test_multiply(32'hFFFF0000, 32'h0000FFFF, 1'b0, 1'b0, "unsigned: 0xFFFF0000 * 0x0000FFFF");
    test_multiply(32'h0000FFFF, 32'hFFFF0000, 1'b0, 1'b0, "unsigned: 0x0000FFFF * 0xFFFF0000");
    test_multiply(32'h12345678, 32'h87654321, 1'b0, 1'b0, "unsigned: 0x12345678 * 0x87654321");
    test_multiply(32'h12345678, 32'h87654321, 1'b1, 1'b1, "signed: 0x12345678 * 0x87654321");

    // ========================================================================
    // 测试组 7: 2的幂次测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 7: 2的幂次测试");
    $display("------------------------------------------------------------");

    test_multiply(32'd1, 32'd1, 1'b0, 1'b0, "2^0 * 2^0");
    test_multiply(32'd2, 32'd2, 1'b0, 1'b0, "2^1 * 2^1");
    test_multiply(32'd4, 32'd4, 1'b0, 1'b0, "2^2 * 2^2");
    test_multiply(32'd8, 32'd8, 1'b0, 1'b0, "2^3 * 2^3");
    test_multiply(32'd16, 32'd16, 1'b0, 1'b0, "2^4 * 2^4");
    test_multiply(32'd256, 32'd256, 1'b0, 1'b0, "2^8 * 2^8");
    test_multiply(32'd65536, 32'd65536, 1'b0, 1'b0, "2^16 * 2^16");

    // ========================================================================
    // 测试组 8: 随机测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 8: 随机测试 (%0d cases)", RANDOM_TESTS);
    $display("------------------------------------------------------------");

    begin : random_tests
      integer i;
      reg [31:0] rand_a, rand_b;
      reg rand_a_sign, rand_b_sign;

      for (i = 0; i < RANDOM_TESTS; i = i + 1) begin
        rand_a      = $random;
        rand_b      = $random;
        rand_a_sign = $random % 2;
        rand_b_sign = $random % 2;
        test_multiply(
            rand_a, rand_b, rand_a_sign, rand_b_sign, $sformatf(
            "random_%0d: 0x%h * 0x%h (%s×%s)", i, rand_a, rand_b, rand_a_sign ? "S" : "U",
            rand_b_sign ? "S" : "U"));
      end
    end

    // ========================================================================
    // 测试组 9: 边界值附近的数
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 9: 边界值附近的数");
    $display("------------------------------------------------------------");

    // 无符号边界附近
    test_multiply(32'hFFFFFFFE, 32'd2, 1'b0, 1'b0, "unsigned: (MAX-1) * 2");
    test_multiply(32'hFFFFFFFE, 32'hFFFFFFFE, 1'b0, 1'b0, "unsigned: (MAX-1) * (MAX-1)");
    test_multiply(32'h00000001, 32'hFFFFFFFE, 1'b0, 1'b0, "unsigned: 1 * (MAX-1)");

    // 有符号边界附近
    test_multiply(32'h7FFFFFFE, 32'd2, 1'b1, 1'b1, "signed: (MAX_INT-1) * 2");
    test_multiply(32'h7FFFFFFE, 32'h7FFFFFFE, 1'b1, 1'b1, "signed: (MAX_INT-1) * (MAX_INT-1)");
    test_multiply(32'h80000001, 32'd2, 1'b1, 1'b1, "signed: (MIN_INT+1) * 2");
    test_multiply(32'h80000001, 32'h80000001, 1'b1, 1'b1, "signed: (MIN_INT+1) * (MIN_INT+1)");
    test_multiply(32'h7FFFFFFE, 32'h80000001, 1'b1, 1'b1, "signed: (MAX_INT-1) * (MIN_INT+1)");

    // ========================================================================
    // 测试组 10: 小负数测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 10: 小负数测试");
    $display("------------------------------------------------------------");

    test_multiply(-32'd2, 32'd2, 1'b1, 1'b1, "signed: -2 * 2");
    test_multiply(-32'd2, -32'd2, 1'b1, 1'b1, "signed: -2 * -2");
    test_multiply(-32'd3, 32'd3, 1'b1, 1'b1, "signed: -3 * 3");
    test_multiply(-32'd3, -32'd3, 1'b1, 1'b1, "signed: -3 * -3");
    test_multiply(-32'd100, 32'd100, 1'b1, 1'b1, "signed: -100 * 100");
    test_multiply(-32'd100, -32'd100, 1'b1, 1'b1, "signed: -100 * -100");
    test_multiply(-32'd1000, 32'd1000, 1'b1, 1'b1, "signed: -1000 * 1000");

    // ========================================================================
    // 测试组 11: 更多位模式测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 11: 更多位模式测试");
    $display("------------------------------------------------------------");

    // 交替位模式
    test_multiply(32'h0F0F0F0F, 32'hF0F0F0F0, 1'b0, 1'b0, "unsigned: 0x0F0F0F0F * 0xF0F0F0F0");
    test_multiply(32'h0F0F0F0F, 32'h0F0F0F0F, 1'b0, 1'b0, "unsigned: 0x0F0F0F0F * 0x0F0F0F0F");
    test_multiply(32'hF0F0F0F0, 32'hF0F0F0F0, 1'b0, 1'b0, "unsigned: 0xF0F0F0F0 * 0xF0F0F0F0");

    // 字节边界模式
    test_multiply(32'h000000FF, 32'hFFFFFF00, 1'b0, 1'b0, "unsigned: 0x000000FF * 0xFFFFFF00");
    test_multiply(32'h0000FF00, 32'h00FF0000, 1'b0, 1'b0, "unsigned: 0x0000FF00 * 0x00FF0000");
    test_multiply(32'h00FF0000, 32'hFF000000, 1'b0, 1'b0, "unsigned: 0x00FF0000 * 0xFF000000");

    // 连续1的模式
    test_multiply(32'h00000003, 32'h00000003, 1'b0, 1'b0, "unsigned: 0x00000003 * 0x00000003");
    test_multiply(32'h00000007, 32'h00000007, 1'b0, 1'b0, "unsigned: 0x00000007 * 0x00000007");
    test_multiply(32'h0000000F, 32'h0000000F, 1'b0, 1'b0, "unsigned: 0x0000000F * 0x0000000F");
    test_multiply(32'h000000FF, 32'h000000FF, 1'b0, 1'b0, "unsigned: 0x000000FF * 0x000000FF");
    test_multiply(32'h0000FFFF, 32'h0000FFFF, 1'b0, 1'b0, "unsigned: 0x0000FFFF * 0x0000FFFF");

    // ========================================================================
    // 测试组 12: Booth编码特殊情况
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 12: Booth编码特殊情况");
    $display("------------------------------------------------------------");

    // 连续的1（Booth编码会转换为减法）
    test_multiply(32'h00000007, 32'd10, 1'b0, 1'b0, "unsigned: 0b111 * 10");
    test_multiply(32'h0000001F, 32'd10, 1'b0, 1'b0, "unsigned: 0b11111 * 10");
    test_multiply(32'h000000FF, 32'd10, 1'b0, 1'b0, "unsigned: 0b11111111 * 10");

    // 连续的0和1交替
    test_multiply(32'h55555555, 32'd3, 1'b0, 1'b0, "unsigned: 0x55555555 * 3");
    test_multiply(32'hAAAAAAAA, 32'd3, 1'b0, 1'b0, "unsigned: 0xAAAAAAAA * 3");

    // 稀疏的1
    test_multiply(32'h80000001, 32'd2, 1'b0, 1'b0, "unsigned: 0x80000001 * 2");
    test_multiply(32'h40000002, 32'd2, 1'b0, 1'b0, "unsigned: 0x40000002 * 2");

    // ========================================================================
    // 测试组 13: 奇偶数组合
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 13: 奇偶数组合");
    $display("------------------------------------------------------------");

    test_multiply(32'd3, 32'd5, 1'b0, 1'b0, "unsigned: 3 * 5 (奇×奇)");
    test_multiply(32'd7, 32'd11, 1'b0, 1'b0, "unsigned: 7 * 11 (奇×奇)");
    test_multiply(32'd2, 32'd4, 1'b0, 1'b0, "unsigned: 2 * 4 (偶×偶)");
    test_multiply(32'd8, 32'd16, 1'b0, 1'b0, "unsigned: 8 * 16 (偶×偶)");
    test_multiply(32'd3, 32'd4, 1'b0, 1'b0, "unsigned: 3 * 4 (奇×偶)");
    test_multiply(32'd5, 32'd8, 1'b0, 1'b0, "unsigned: 5 * 8 (奇×偶)");

    // ========================================================================
    // 测试组 14: 质数相乘
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 14: 质数相乘");
    $display("------------------------------------------------------------");

    test_multiply(32'd2, 32'd3, 1'b0, 1'b0, "unsigned: 2 * 3");
    test_multiply(32'd3, 32'd5, 1'b0, 1'b0, "unsigned: 3 * 5");
    test_multiply(32'd5, 32'd7, 1'b0, 1'b0, "unsigned: 5 * 7");
    test_multiply(32'd7, 32'd11, 1'b0, 1'b0, "unsigned: 7 * 11");
    test_multiply(32'd11, 32'd13, 1'b0, 1'b0, "unsigned: 11 * 13");
    test_multiply(32'd13, 32'd17, 1'b0, 1'b0, "unsigned: 13 * 17");
    test_multiply(32'd17, 32'd19, 1'b0, 1'b0, "unsigned: 17 * 19");
    test_multiply(32'd97, 32'd101, 1'b0, 1'b0, "unsigned: 97 * 101");

    // ========================================================================
    // 测试组 15: 大质数
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 15: 大质数");
    $display("------------------------------------------------------------");

    test_multiply(32'd65521, 32'd65537, 1'b0, 1'b0, "unsigned: 65521 * 65537");
    test_multiply(32'd32749, 32'd32771, 1'b0, 1'b0, "unsigned: 32749 * 32771");

    // ========================================================================
    // 测试组 16: 符号位边界
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 16: 符号位边界");
    $display("------------------------------------------------------------");

    test_multiply(32'h7FFFFFFF, 32'd2, 1'b0, 1'b0, "unsigned: 0x7FFFFFFF * 2");
    test_multiply(32'h7FFFFFFF, 32'd2, 1'b1, 1'b1, "signed: 0x7FFFFFFF * 2");
    test_multiply(32'h80000000, 32'd2, 1'b0, 1'b0, "unsigned: 0x80000000 * 2");
    test_multiply(32'h80000000, 32'd2, 1'b1, 1'b1, "signed: 0x80000000 * 2");

    // ========================================================================
    // 测试组 17: 写使能测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 17: 写使能测试");
    $display("------------------------------------------------------------");

    mul_a_i    = 32'h12345678;
    mul_b_i    = 32'h87654321;
    mul_a_sign = 1'b0;
    mul_b_sign = 1'b0;
    mul_we     = 1'b0;  // 禁用写使能

    #(CLOCK_PERIOD);

    test_count = test_count + 1;
    if (mul_result === 64'bx) begin
      pass_count = pass_count + 1;
      $display("[PASS] Test %0d: Write enable disabled - output is high-Z", test_count);
    end else begin
      fail_count = fail_count + 1;
      $display("[FAIL] Test %0d: Write enable disabled - output should be high-Z", test_count);
      $display("       result=0x%h (expected=64'bx)", mul_result);
    end
    $display("");

    // ========================================================================
    // 测试总结
    // ========================================================================
    $display("============================================================");
    $display("测试完成");
    $display("============================================================");
    $display("总测试数: %0d", test_count);
    $display("通过数量: %0d", pass_count);
    $display("失败数量: %0d", fail_count);
    $display("通过率: %0.2f%%", (pass_count * 100.0) / test_count);
    $display("============================================================");

    if (fail_count == 0) begin
      $display("✓ 所有测试通过！乘法器功能正确");
    end else begin
      $display("✗ 发现 %0d 个错误，需要调试", fail_count);
    end
    $display("============================================================");

    #(CLOCK_PERIOD * 5);
    $finish;
  end

  // ============================================================================
  // 波形记录
  // ============================================================================
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // ============================================================================
  // 超时保护
  // ============================================================================
  initial begin
    #100000;  // 100us timeout
    $display("ERROR: Simulation timeout!");
    $finish;
  end

endmodule
