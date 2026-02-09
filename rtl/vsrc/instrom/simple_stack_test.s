# 简单的栈测试程序
.section .text
.globl _start

_start:
    # 初始化栈指针
    li sp, 0x8000F000

    # 测试栈操作
    li t0, 0x12345678
    sw t0, -4(sp)
    lw t1, -4(sp)

    # 测试函数调用
    jal ra, test_func

    # 写入tohost表示成功
    li t0, 0x80001000
    li t1, 1
    sw t1, 0(t0)

loop:
    j loop

test_func:
    # 保存寄存器到栈
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)

    # 做一些计算
    li s0, 100
    addi s0, s0, 23

    # 恢复寄存器
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
