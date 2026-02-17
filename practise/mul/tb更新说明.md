# tb.v 更新说明 - 支持有符号×无符号乘法

## 📋 更新内容

### 1. 接口变化

**原接口：**
```verilog
reg mul_sign;  // 单一符号控制
```

**新接口：**
```verilog
reg mul_a_sign;  // 操作数A的符号控制
reg mul_b_sign;  // 操作数B的符号控制
```

### 2. 支持的乘法模式

| 模式 | mul_a_sign | mul_b_sign | 说明 | RISC-V指令 |
|------|-----------|-----------|------|-----------|
| 无符号×无符号 | 0 | 0 | 两个操作数都是无符号数 | MUL, MULHU |
| 有符号×有符号 | 1 | 1 | 两个操作数都是有符号数 | MUL, MULH |
| 有符号×无符号 | 1 | 0 | A是有符号，B是无符号 | MULHSU |
| 无符号×有符号 | 0 | 1 | A是无符号，B是有符号 | (不常用) |

### 3. 新增测试组

**测试组 5: 有符号×无符号乘法 (MULHSU)** ⭐ 新增

包含 12 个测试用例：
- 基本测试：1×1, 10×20, -1×1, -5×10, -10×100
- 边界值：MAX_INT×MAX_UINT, MIN_INT×MAX_UINT, -1×MAX_UINT
- 特殊模式：-2×2^31, -100×0x12345678

**测试示例：**
```verilog
test_multiply(-32'd5, 32'd10, 1'b1, 1'b0, "MULHSU: -5 * 10");
// 结果：-5 * 10 = -50 (0xFFFFFFFFFFFFFFCE)
```

### 4. 测试任务更新

**原任务签名：**
```verilog
task test_multiply(
    input [31:0] a,
    input [31:0] b,
    input is_signed,
    input string test_name
);
```

**新任务签名：**
```verilog
task test_multiply(
    input [31:0] a,
    input [31:0] b,
    input a_signed,
    input b_signed,
    input string test_name
);
```

### 5. 期望结果计算

```verilog
if (a_signed && b_signed) begin
    // 有符号 × 有符号
    expected_result = $signed(a) * $signed(b);
end else if (a_signed && !b_signed) begin
    // 有符号 × 无符号 (MULHSU)
    expected_result = $signed(a) * $signed({1'b0, b});
end else if (!a_signed && b_signed) begin
    // 无符号 × 有符号
    expected_result = $signed({1'b0, a}) * $signed(b);
end else begin
    // 无符号 × 无符号
    expected_result = a * b;
end
```

## 📊 测试统计

### 测试组数量：17 组（原16组 + 新增1组）

| 测试组 | 测试用例数 | 说明 |
|--------|-----------|------|
| 1. 基本无符号乘法 | 6 | 0×0, 1×1, 2×3, 10×20, 100×100, 1000×1000 |
| 2. 边界值测试（无符号） | 7 | MAX_UINT相关测试 |
| 3. 基本有符号乘法 | 10 | 正负数组合 |
| 4. 有符号边界值 | 10 | MAX_INT, MIN_INT相关 |
| **5. 有符号×无符号 (MULHSU)** | **12** | **⭐ 新增** |
| 6. 位模式测试 | 7 | 交替位、半字边界 |
| 7. 2的幂次测试 | 7 | 2^0 到 2^16 |
| 8. 随机测试 | 50 | 随机生成 |
| 9. 边界值附近的数 | 8 | MAX±1, MIN±1 |
| 10. 小负数测试 | 7 | -2, -3, -100, -1000 |
| 11. 更多位模式 | 11 | 连续1、字节边界 |
| 12. Booth编码特殊情况 | 7 | 连续1、稀疏1 |
| 13. 奇偶数组合 | 6 | 奇×奇、偶×偶、奇×偶 |
| 14. 质数相乘 | 8 | 小质数到中等质数 |
| 15. 大质数 | 2 | 65521×65537 |
| 16. 符号位边界 | 4 | 0x7FFFFFFF, 0x80000000 |
| 17. 写使能测试 | 1 | mul_we=0 |
| **总计** | **约 163** | **完整覆盖** |

## 🎯 MULHSU 测试用例详解

### 基本测试
```verilog
test_multiply(32'd1, 32'd1, 1'b1, 1'b0, "MULHSU: 1 * 1");
// 1 * 1 = 1

test_multiply(-32'd1, 32'd1, 1'b1, 1'b0, "MULHSU: -1 * 1");
// -1 * 1 = -1 (0xFFFFFFFFFFFFFFFF)

test_multiply(-32'd5, 32'd10, 1'b1, 1'b0, "MULHSU: -5 * 10");
// -5 * 10 = -50 (0xFFFFFFFFFFFFFFCE)
```

### 边界值测试
```verilog
test_multiply(32'h7FFFFFFF, 32'hFFFFFFFF, 1'b1, 1'b0, "MULHSU: MAX_INT * MAX_UINT");
// 2147483647 * 4294967295 = 0x7FFFFFFE80000001

test_multiply(32'h80000000, 32'hFFFFFFFF, 1'b1, 1'b0, "MULHSU: MIN_INT * MAX_UINT");
// -2147483648 * 4294967295 = 0xFFFFFFFF80000000

test_multiply(-32'd1, 32'hFFFFFFFF, 1'b1, 1'b0, "MULHSU: -1 * MAX_UINT");
// -1 * 4294967295 = -4294967295 (0xFFFFFFFF00000001)
```

## 🚀 使用方法

### 运行测试
```bash
cd /home/jay/Desktop/graduation_project/rtl/mul
make -f Makefile.tb all
```

### 查看结果
```bash
cat test.log | grep "测试组 5"
```

### 查看MULHSU测试结果
```bash
grep "MULHSU" test.log
```

## ✅ 预期输出

成功时应该看到：
```
------------------------------------------------------------
测试组 5: 有符号×无符号乘法 (MULHSU)
------------------------------------------------------------
[PASS] Test XX: MULHSU: 1 * 1
       a=0x00000001, b=0x00000001, a_sign=1, b_sign=0
       result=0x0000000000000001 (expected=0x0000000000000001)

[PASS] Test XX: MULHSU: -5 * 10
       a=0xfffffffb, b=0x0000000a, a_sign=1, b_sign=0
       result=0xffffffffffffffce (expected=0xffffffffffffffce)

...

============================================================
测试完成
============================================================
总测试数: 163
通过数量: 163
失败数量: 0
通过率: 100.00%
============================================================
✓ 所有测试通过！乘法器功能正确
============================================================
```

## 📝 注意事项

1. **符号扩展**：在MULHSU模式下，无符号操作数B会被零扩展到33位，然后作为有符号数参与运算
2. **结果解释**：MULHSU的结果是64位有符号数
3. **RISC-V对应**：MULHSU指令返回高32位，但测试中我们验证完整的64位结果

## 🔍 调试提示

如果测试失败，检查：
1. booth.v 中的符号扩展逻辑
2. mul_top.v 中的 mul_a_sign 和 mul_b_sign 连接
3. 期望结果的计算是否正确

查看失败的测试：
```bash
grep "\[FAIL\]" test.log
```
