.section .text
.globl _start
.option norvc
.option norelax
_start:
  li x3, 0
  li s0, 0
  la s1, victim
  j victim
victim:
  jal t2, old_target
fallthrough:
  li t0, 2
  bne s0, t0, fail
  li x3, 1
  .rept 8
  nop
  .endr
hang:
  j hang
old_target:
  addi s0, s0, 1
  li t0, 2
  beq s0, t0, patch
  blt s0, t0, victim
  j fail
patch:
  # The JAL has executed twice and its BTB target is warm. Replace it with NOP.
  li t0, 0x00000013
  sw t0, 0(s1)
  fence.i
  jalr x0, 0(s1)
fail:
  li x3, 2
  j hang
