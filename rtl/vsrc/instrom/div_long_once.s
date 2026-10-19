.section .text
.globl _start
.option norvc

_start:
  addi x3, x0, 0
  addi x5, x0, -1
  addi x6, x0, 3
  nop
  nop
  nop

div_long_once:
  divu x7, x5, x6          # The only division instruction.
  addi x8, x7, 0          # Check dependent result forwarding.
  li x9, 1431655765
  bne x8, x9, fail
  addi x3, x0, 1
  j hang
fail:
  addi x3, x0, 2
hang:
  j hang
