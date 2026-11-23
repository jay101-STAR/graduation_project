.option norvc
.section .text
.globl _start
_start:
  # Cross both a word and a 64-byte cache-line boundary through the existing LSU.
  li s0, 0x8000203c
  sw zero, 0(s0)
  sw zero, 4(s0)
  addi s0, s0, 3
  li t0, 0x89abcdef
  sw t0, 0(s0)
  lw t1, 0(s0)
  bne t0, t1, fail
  lb t1, 0(s0)
  li t2, -17
  bne t1, t2, fail
  lbu t1, 0(s0)
  li t2, 239
  bne t1, t2, fail
  lh t1, 0(s0)
  li t2, 0xffffcdef
  bne t1, t2, fail
  lhu t1, 0(s0)
  li t2, 0xcdef
  bne t1, t2, fail
  li t0, 0x1122
  sh t0, 1(s0)
  li t0, 0x44
  sb t0, 3(s0)
  lw t1, 0(s0)
  li t2, 0x441122ef
  bne t1, t2, fail

  # Five tags in one four-way set force dirty replacement and subsequent refill.
  li s0, 0x80002280
  li t0, 0
  li t3, 8192
  li t4, 5
store_lines:
  addi t1, t0, 256
  sw t1, 0(s0)
  add s0, s0, t3
  addi t0, t0, 1
  blt t0, t4, store_lines
  li s0, 0x80002280
  li t0, 0
read_lines:
  lw t1, 0(s0)
  addi t2, t0, 256
  bne t1, t2, fail
  add s0, s0, t3
  addi t0, t0, 1
  blt t0, t4, read_lines

  # Warm ICache, modify instructions through DCache, and synchronize twice.
  la s0, patched_target
  jalr ra, s0, 0
  li t0, 1
  bne a0, t0, fail
  li t0, 0x00200513
  sw t0, 0(s0)
  fence.i
  jalr ra, s0, 0
  li t0, 2
  bne a0, t0, fail
  li t0, 0x00300513
  sw t0, 0(s0)
  fence.i
  jalr ra, s0, 0
  li t0, 3
  bne a0, t0, fail
  li t0, 1
  li t1, 0x80001000
  sw t0, 0(t1)
  li gp, 1
pass:
  j pass
fail:
  li t0, 3
  li t1, 0x80001000
  sw t0, 0(t1)
  li gp, 3
failed:
  j failed

.balign 64
patched_target:
  addi a0, zero, 1
  jalr zero, ra, 0
