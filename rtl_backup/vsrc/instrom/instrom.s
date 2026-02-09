.section .text
.globl _start

_start:
  # 1. 准备数据
addi x1, x0, 5      # x1 = 5
addi x2, x0, 6      # x2 = 6
# 2. 执行乘法 (关键点)
# 预期结果: x4 应该等于 30 (十六进制 0x1E)
# 如果你的位宽 bug 还没修好，这里 x4 可能会变成 0 或 1
mul x4, x1, x2      
# 3. 准备预期结果用于对比
addi x5, x0, 30     # x5 = 30 (预期值)
# 4. 计算差值
sub x6, x4, x5      # x6 = 计算结果 - 预期结果
                    # 如果正确，x6 应该是 0
# 5. 生成最终标志 (利用 SLTIU技巧)
# sltiu: Set Less Than Immediate Unsigned
# 如果 x6 < 1 (即 x6 为 0)，则 x3 = 1；否则 x3 = 0
addi x3, x6, 1
