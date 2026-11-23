.section .text
.globl _start
.option norvc
.option norelax
_start:
  li gp, 0
  li s0, 0x80006000
  li t0, 0x80ff7f01
  sw t0, 0(s0)
  li t0, 0x11223344
  sw t0, 4(s0)
  lb t1, 3(s0)
  li t2, -128
  bne t1, t2, fail
  lbu t1, 2(s0)
  li t2, 255
  bne t1, t2, fail
  lh t1, 1(s0)
  li t2, -129
  bne t1, t2, fail
  lhu t1, 3(s0)
  li t2, 0x4480
  bne t1, t2, fail
  # Cross-word store/read must merge both transactions exactly once.
  li t0, 0xdeadbeef
  sw t0, 1(s0)
  lw t1, 1(s0)
  bne t1, t0, fail
  lw t1, 0(s0)
  li t2, 0xadbeef01
  bne t1, t2, fail
  lw t1, 4(s0)
  li t2, 0x112233de
  bne t1, t2, fail
  li t0, 0xa1b2
  sh t0, 3(s0)
  lhu t1, 3(s0)
  bne t1, t0, fail
  li t0, 0x5a
  sb t0, 2(s0)
  lbu t1, 2(s0)
  bne t1, t0, fail
  # Both lanes of the last physical word, without wrapping the RAM image.
  li s1, 0x8000fffc
  li t0, 0xa5a55a5a
  sw t0, 0(s1)
  lb t1, 3(s1)
  li t2, -91
  bne t1, t2, fail
  li t0, 0xcafe
  sh t0, 2(s1)
  lw t1, 0(s1)
  li t2, 0xcafe5a5a
  bne t1, t2, fail
  # Switch between RAM and UART slaves, preserving normal UART operation.
  li s2, 0x10000000
  lw t0, 4(s2)
  andi t0, t0, 1
  beqz t0, fail
  li t0, 0x41
  sb t0, 0(s2)
  li t0, 0x12345678
  sw t0, 8(s0)
  lw t1, 8(s0)
  bne t1, t0, fail
1:
  lw t0, 4(s2)
  andi t0, t0, 1
  beqz t0, 1b
  li s0, 0x80001000
  li t0, 1
  sw t0, 0(s0)
  j .
fail:
  li gp, 2
  j .
