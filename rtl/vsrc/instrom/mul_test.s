.section .text
.globl _start

_start:
    # 初始化寄存器
    li x1, 5          # x1 = 5
    li x2, 3          # x2 = 3

    # 测试 MUL 指令 (5 * 3 = 15)
    mul x3, x1, x2    # x3 应该 = 15

    # 测试 MULH 指令 (有符号高位)
    li x4, -2         # x4 = -2
    li x5, 3          # x5 = 3
    mulh x6, x4, x5   # x6 应该 = -1 (高32位)

    # 测试 MULHU 指令 (无符号高位)
    li x7, 0xFFFFFFFF # x7 = 4294967295
    li x8, 2          # x8 = 2
    mulhu x9, x7, x8  # x9 应该 = 1 (高32位)

    # 测试 MULHSU 指令 (有符号×无符号高位)
    li x10, -1        # x10 = -1 (有符号)
    li x11, 2         # x11 = 2 (无符号)
    mulhsu x12, x10, x11  # x12 应该 = -1 (高32位)

    # 写入 tohost 表示测试完成
    li x13, 0x80001000
    li x14, 1
    sw x14, 0(x13)

    # 无限循环
loop:
    j loop
