`timescale 1ns / 1ps

// ============================================================================
// 乘法器综合测试平台
// 测试 32位 Booth Radix-4 乘法器的正确性
// ============================================================================

module tb_multiplier;

  // ============================================================================
  // 测试参数
  // ============================================================================
  parameter RANDOM_TESTS = 50;  // 随机测试数量
  parameter CLOCK_PERIOD = 10;  // 时钟周期 (ns)

  // ============================================================================
  // 测试信号
  // ============================================================================
  reg            clk;
  reg     [31:0] mul_a;
  reg     [31:0] mul_b;
  reg            mul_sign;
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
  multiplier dut (
      .mul_a_i     (mul_a),
      .mul_b_i     (mul_b),
      .mul_sign    (mul_sign),
      .mul_we      (mul_we),
      .mul_result_o(mul_result)
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
    input is_signed;
    input string test_name;
    begin
      test_count = test_count + 1;

      // 设置输入
      mul_a      = a;
      mul_b      = b;
      mul_sign   = is_signed;
      mul_we     = 1'b1;

      // 计算期望结果
      if (is_signed) begin
        // 有符号乘法
        signed_result   = $signed(a) * $signed(b);
        expected_result = signed_result;
      end else begin
        // 无符号乘法
        unsigned_result = a * b;
        expected_result = unsigned_result;
      end

      // 等待组合逻辑稳定
      #(CLOCK_PERIOD);

      // 检查结果
      if (mul_result === expected_result) begin
        pass_count = pass_count + 1;
        $display("[PASS] Test %0d: %s", test_count, test_name);
        $display("       a=0x%h, b=0x%h, sign=%b", a, b, is_signed);
        $display("       result=0x%h (expected=0x%h)", mul_result, expected_result);
      end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Test %0d: %s", test_count, test_name);
        $display("       a=0x%h (%0d), b=0x%h (%0d), sign=%b", a, $signed(a), b, $signed(b),
                 is_signed);
        $display("       result  =0x%h", mul_result);
        $display("       expected=0x%h", expected_result);
        if (is_signed) begin
          $display("       signed: %0d * %0d = %0d (expected %0d)", $signed(a), $signed(b),
                   $signed(mul_result), $signed(expected_result));
        end else begin
          $display("       unsigned: %0d * %0d = %0d (expected %0d)", a, b, mul_result,
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
    mul_a      = 0;
    mul_b      = 0;
    mul_sign   = 0;
    mul_we     = 0;

    $display("============================================================");
    $display("乘法器测试开始");
    $display("测试模块: multiplier (32-bit Booth Radix-4)");
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

    test_multiply(32'd0, 32'd0, 1'b0, "0 * 0");
    test_multiply(32'd1, 32'd1, 1'b0, "1 * 1");
    test_multiply(32'd2, 32'd3, 1'b0, "2 * 3");
    test_multiply(32'd10, 32'd20, 1'b0, "10 * 20");
    test_multiply(32'd100, 32'd100, 1'b0, "100 * 100");
    test_multiply(32'd1000, 32'd1000, 1'b0, "1000 * 1000");

    // ========================================================================
    // 测试组 2: 边界值测试（无符号）
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 2: 边界值测试（无符号）");
    $display("------------------------------------------------------------");

    test_multiply(32'd0, 32'hFFFFFFFF, 1'b0, "0 * MAX_UINT");
    test_multiply(32'hFFFFFFFF, 32'd0, 1'b0, "MAX_UINT * 0");
    test_multiply(32'd1, 32'hFFFFFFFF, 1'b0, "1 * MAX_UINT");
    test_multiply(32'hFFFFFFFF, 32'd1, 1'b0, "MAX_UINT * 1");
    test_multiply(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, "MAX_UINT * MAX_UINT");
    test_multiply(32'h80000000, 32'd2, 1'b0, "2^31 * 2");
    test_multiply(32'h7FFFFFFF, 32'd2, 1'b0, "(2^31-1) * 2");

    // ========================================================================
    // 测试组 3: 基本有符号乘法
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 3: 基本有符号乘法");
    $display("------------------------------------------------------------");

    test_multiply(32'd0, 32'd0, 1'b1, "signed: 0 * 0");
    test_multiply(32'd1, 32'd1, 1'b1, "signed: 1 * 1");
    test_multiply(32'd2, 32'd3, 1'b1, "signed: 2 * 3");
    test_multiply(32'd10, 32'd20, 1'b1, "signed: 10 * 20");
    test_multiply(-32'd1, 32'd1, 1'b1, "signed: -1 * 1");
    test_multiply(32'd1, -32'd1, 1'b1, "signed: 1 * -1");
    test_multiply(-32'd1, -32'd1, 1'b1, "signed: -1 * -1");
    test_multiply(-32'd5, 32'd10, 1'b1, "signed: -5 * 10");
    test_multiply(32'd10, -32'd5, 1'b1, "signed: 10 * -5");
    test_multiply(-32'd10, -32'd5, 1'b1, "signed: -10 * -5");

    // ========================================================================
    // 测试组 4: 有符号边界值
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 4: 有符号边界值");
    $display("------------------------------------------------------------");

    test_multiply(32'h7FFFFFFF, 32'd1, 1'b1, "signed: MAX_INT * 1");
    test_multiply(32'd1, 32'h7FFFFFFF, 1'b1, "signed: 1 * MAX_INT");
    test_multiply(32'h7FFFFFFF, 32'h7FFFFFFF, 1'b1, "signed: MAX_INT * MAX_INT");
    test_multiply(32'h80000000, 32'd1, 1'b1, "signed: MIN_INT * 1");
    test_multiply(32'd1, 32'h80000000, 1'b1, "signed: 1 * MIN_INT");
    test_multiply(32'h80000000, 32'h80000000, 1'b1, "signed: MIN_INT * MIN_INT");
    test_multiply(32'h7FFFFFFF, 32'h80000000, 1'b1, "signed: MAX_INT * MIN_INT");
    test_multiply(32'h80000000, 32'h7FFFFFFF, 1'b1, "signed: MIN_INT * MAX_INT");
    test_multiply(32'h80000000, -32'd1, 1'b1, "signed: MIN_INT * -1");
    test_multiply(-32'd1, 32'h80000000, 1'b1, "signed: -1 * MIN_INT");

    // ========================================================================
    // 测试组 5: 位模式测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 5: 位模式测试");
    $display("------------------------------------------------------------");

    test_multiply(32'hAAAAAAAA, 32'h55555555, 1'b0, "unsigned: 0xAAAAAAAA * 0x55555555");
    test_multiply(32'h55555555, 32'hAAAAAAAA, 1'b0, "unsigned: 0x55555555 * 0xAAAAAAAA");
    test_multiply(32'hAAAAAAAA, 32'h55555555, 1'b1, "signed: 0xAAAAAAAA * 0x55555555");
    test_multiply(32'hFFFF0000, 32'h0000FFFF, 1'b0, "unsigned: 0xFFFF0000 * 0x0000FFFF");
    test_multiply(32'h0000FFFF, 32'hFFFF0000, 1'b0, "unsigned: 0x0000FFFF * 0xFFFF0000");
    test_multiply(32'h12345678, 32'h87654321, 1'b0, "unsigned: 0x12345678 * 0x87654321");
    test_multiply(32'h12345678, 32'h87654321, 1'b1, "signed: 0x12345678 * 0x87654321");

    // ========================================================================
    // 测试组 6: 2的幂次测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 6: 2的幂次测试");
    $display("------------------------------------------------------------");

    test_multiply(32'd1, 32'd1, 1'b0, "2^0 * 2^0");
    test_multiply(32'd2, 32'd2, 1'b0, "2^1 * 2^1");
    test_multiply(32'd4, 32'd4, 1'b0, "2^2 * 2^2");
    test_multiply(32'd8, 32'd8, 1'b0, "2^3 * 2^3");
    test_multiply(32'd16, 32'd16, 1'b0, "2^4 * 2^4");
    test_multiply(32'd256, 32'd256, 1'b0, "2^8 * 2^8");
    test_multiply(32'd65536, 32'd65536, 1'b0, "2^16 * 2^16");

    // ========================================================================
    // 测试组 7: 随机测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 7: 随机测试 (%0d cases)", RANDOM_TESTS);
    $display("------------------------------------------------------------");

    begin : random_tests
      integer i;
      reg [31:0] rand_a, rand_b;
      reg rand_sign;

      for (i = 0; i < RANDOM_TESTS; i = i + 1) begin
        rand_a    = $random;
        rand_b    = $random;
        rand_sign = $random % 2;
        test_multiply(
            rand_a, rand_b, rand_sign, $sformatf(
            "random_%0d: 0x%h * 0x%h (%s)", i, rand_a, rand_b, rand_sign ? "signed" : "unsigned"));
      end
    end

    // ========================================================================
    // 测试组 8: 写使能测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 8: 写使能测试");
    $display("------------------------------------------------------------");

    mul_a    = 32'h12345678;
    mul_b    = 32'h87654321;
    mul_sign = 1'b0;
    mul_we   = 1'b0;  // 禁用写使能

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
    $dumpfile("tb_multiplier.vcd");
    $dumpvars(0, tb_multiplier);
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
