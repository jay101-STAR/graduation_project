.section .text
.globl _start

_start:
    # 简单的乘法测试
    li x1, 5          # x1 = 5
    li x2, 3          # x2 = 3
    mul x3, x1, x2    # x3 = 5 * 3 = 15

    # 将结果写入内存以便观察
    li x4, 0x80002000
    sw x3, 0(x4)

    # 写入 tohost 表示测试完成
    li x5, 0x80001000
    li x6, 1
    sw x6, 0(x5)

    # 无限循环
loop:
    j loop
