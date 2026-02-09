`timescale 1ns / 1ps

// ============================================================================
// 3周期乘法器测试平台
// ============================================================================

module tb_mul_3cycle;

  // ============================================================================
  // 测试参数
  // ============================================================================
  parameter CLOCK_PERIOD = 10;  // 时钟周期 (ns)
  parameter RANDOM_TESTS = 20;  // 随机测试数量

  // ============================================================================
  // 测试信号
  // ============================================================================
  reg            clk;
  reg            rst_n;
  reg     [31:0] mul_a_i;
  reg     [31:0] mul_b_i;
  reg            mul_a_sign;
  reg            mul_b_sign;
  reg            mul_start;
  wire    [63:0] mul_result;
  wire           mul_done;
  wire           mul_busy;

  // 测试统计
  integer        test_count;
  integer        pass_count;
  integer        fail_count;

  // 期望结果
  reg     [63:0] expected_result;

  // ============================================================================
  // 实例化被测模块
  // ============================================================================
  mul_3cycle dut (
      .clk       (clk),
      .rst_n     (rst_n),
      .mul_a_i   (mul_a_i),
      .mul_b_i   (mul_b_i),
      .mul_a_sign(mul_a_sign),
      .mul_b_sign(mul_b_sign),
      .mul_start (mul_start),
      .mul_result(mul_result),
      .mul_done  (mul_done),
      .mul_busy  (mul_busy)
  );

  // ============================================================================
  // 时钟生成
  // ============================================================================
  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD / 2) clk = ~clk;
  end

  // ============================================================================
  // 测试任务
  // ============================================================================
  task test_multiply;
    input [31:0] a;
    input [31:0] b;
    input a_signed;
    input b_signed;
    input string test_name;
    begin
      test_count = test_count + 1;

      // 计算期望结果
      if (a_signed && b_signed) begin
        expected_result = $signed(a) * $signed(b);
      end else if (a_signed && !b_signed) begin
        expected_result = $signed(a) * $signed({1'b0, b});
      end else if (!a_signed && b_signed) begin
        expected_result = $signed({1'b0, a}) * $signed(b);
      end else begin
        expected_result = a * b;
      end

      // 启动乘法
      mul_a_i    = a;
      mul_b_i    = b;
      mul_a_sign = a_signed;
      mul_b_sign = b_signed;
      mul_start  = 1'b1;
      @(posedge clk);
      mul_start = 1'b0;

      // 等待完成（最多等待5个周期）
      repeat (5) begin
        @(posedge clk);
        if (mul_done) break;
      end

      // 检查结果
      if (mul_result === expected_result) begin
        pass_count = pass_count + 1;
        $display("[PASS] Test %0d: %s", test_count, test_name);
        $display("       a=0x%h, b=0x%h, a_sign=%b, b_sign=%b", a, b, a_signed, b_signed);
        $display("       result=0x%h (expected=0x%h)", mul_result, expected_result);
      end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Test %0d: %s", test_count, test_name);
        $display("       a=0x%h, b=0x%h, a_sign=%b, b_sign=%b", a, b, a_signed, b_signed);
        $display("       result  =0x%h", mul_result);
        $display("       expected=0x%h", expected_result);
      end
      $display("");

      // 等待一个周期
      @(posedge clk);
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
    rst_n      = 0;
    mul_a_i    = 0;
    mul_b_i    = 0;
    mul_a_sign = 0;
    mul_b_sign = 0;
    mul_start  = 0;

    $display("============================================================");
    $display("3周期乘法器测试开始");
    $display("============================================================");
    $display("");

    // 复位
    #(CLOCK_PERIOD * 2);
    rst_n = 1;
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

    // ========================================================================
    // 测试组 2: 边界值测试（无符号）
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 2: 边界值测试（无符号）");
    $display("------------------------------------------------------------");

    test_multiply(32'hFFFFFFFF, 32'd1, 1'b0, 1'b0, "MAX_UINT * 1");
    test_multiply(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, 1'b0, "MAX_UINT * MAX_UINT");
    test_multiply(32'h80000000, 32'd2, 1'b0, 1'b0, "2^31 * 2");

    // ========================================================================
    // 测试组 3: 基本有符号乘法
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 3: 基本有符号乘法");
    $display("------------------------------------------------------------");

    test_multiply(32'd1, 32'd1, 1'b1, 1'b1, "signed: 1 * 1");
    test_multiply(-32'd1, 32'd1, 1'b1, 1'b1, "signed: -1 * 1");
    test_multiply(-32'd1, -32'd1, 1'b1, 1'b1, "signed: -1 * -1");
    test_multiply(-32'd5, 32'd10, 1'b1, 1'b1, "signed: -5 * 10");

    // ========================================================================
    // 测试组 4: 有符号边界值
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 4: 有符号边界值");
    $display("------------------------------------------------------------");

    test_multiply(32'h7FFFFFFF, 32'd1, 1'b1, 1'b1, "signed: MAX_INT * 1");
    test_multiply(32'h80000000, 32'd1, 1'b1, 1'b1, "signed: MIN_INT * 1");
    test_multiply(32'h7FFFFFFF, 32'h7FFFFFFF, 1'b1, 1'b1, "signed: MAX_INT * MAX_INT");

    // ========================================================================
    // 测试组 5: 有符号×无符号 (MULHSU)
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 5: 有符号×无符号 (MULHSU)");
    $display("------------------------------------------------------------");

    test_multiply(32'd10, 32'd20, 1'b1, 1'b0, "MULHSU: 10 * 20");
    test_multiply(-32'd5, 32'd10, 1'b1, 1'b0, "MULHSU: -5 * 10");
    test_multiply(32'h7FFFFFFF, 32'hFFFFFFFF, 1'b1, 1'b0, "MULHSU: MAX_INT * MAX_UINT");

    // ========================================================================
    // 测试组 6: 随机测试
    // ========================================================================
    $display("------------------------------------------------------------");
    $display("测试组 6: 随机测试 (%0d cases)", RANDOM_TESTS);
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
        test_multiply(rand_a, rand_b, rand_a_sign, rand_b_sign, $sformatf(
                      "random_%0d: 0x%h * 0x%h (%s×%s)",
                      i,
                      rand_a,
                      rand_b,
                      rand_a_sign ? "S" : "U",
                      rand_b_sign ? "S" : "U"
                      ));
      end
    end

    // ========================================================================
    // 测试总结
    // ========================================================================
    $display("============================================================");
    $display("测试完成");
    $display("============================================================");
    $display("总测试数: %0d", test_count);
    $display("通过数量: %0d", pass_count);
    $display("失败数量: %0d", fail_count);
    if (test_count > 0) $display("通过率: %0.2f%%", (pass_count * 100.0) / test_count);
    $display("============================================================");

    if (fail_count == 0) begin
      $display("✓ 所有测试通过！3周期乘法器功能正确");
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
    $dumpfile("tb_mul_3cycle.vcd");
    $dumpvars(0, tb_mul_3cycle);
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
