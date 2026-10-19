.section .text
.globl _start
.option norvc

_start:
  addi x3, x0, 0
  addi x5, x0, 100
  addi x6, x0, 1
  nop
  nop
  nop

div_fast_once:
  div x7, x5, x6          # The only division instruction.
  addi x8, x7, 0          # Check dependent result forwarding.
  li x9, 100
  bne x8, x9, fail
  addi x3, x0, 1
  j hang
fail:
  addi x3, x0, 2
hang:
  j hang
