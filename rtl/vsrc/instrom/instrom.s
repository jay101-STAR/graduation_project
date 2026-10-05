.section .text
.globl _start

_start:
  # 1. 准备操作数
  addi x1, x0, 5          # x1 = 5
  addi x2, x0, 7          # x2 = 7

  # 2. 执行加法指令：x3 = x1 + x2 = 12
  add  x3, x1, x2

  # 3. 检查 x3 的结果是否等于 12
  addi x4, x0, 12
  addi x0, x0, 0
  addi x0, x0, 0
  bne  x3, x4, test_fail

test_pass:
  addi x5, x0, 1          # tohost = 1 表示通过
  lui  x6, 0x80001        # x6 = 0x80001000
  addi x0, x0, 0
  sw   x5, 0(x6)

pass_hang:
  jal  x0, pass_hang

test_fail:
  addi x5, x0, 2          # tohost = 2 表示失败
  lui  x6, 0x80001        # x6 = 0x80001000
  addi x0, x0, 0
  sw   x5, 0(x6)

fail_hang:
  jal  x0, fail_hang
