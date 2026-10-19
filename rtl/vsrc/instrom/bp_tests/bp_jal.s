.section .text
.globl _start
.option norvc
.option norelax
_start:
  li x3, 0
  li s0, 16
loop:
  # No unresolved la relocation: PC+12 is the following JAL's return address.
  auipc t3, 0
  addi t3, t3, 12
  jal t2, target
  j fail
target:
  bne t2, t3, fail
  addi s0, s0, -1
  bne s0, x0, loop

  li s0, 12
chain_loop:
  auipc s1, 0
  addi s1, s1, 12
  jal ra, chain_first
  j fail
chain_first:
  # Two adjacent JALs must preserve prediction metadata and both link writes.
  jal t0, chain_second
  j fail
chain_second:
  bne ra, s1, fail
  addi t3, s1, 8
  bne t0, t3, fail
  addi s0, s0, -1
  bne s0, x0, chain_loop

  # Three targets with identical BTB set indexes compete for two ways.
  li s0, 6
  j alias_a
alias_return:
  addi s0, s0, -1
  bne s0, x0, alias_a
  li x3, 1
  .rept 8
  nop
  .endr
hang:
  j hang
fail:
  li x3, 2
  j hang

.p2align 9
alias_a:
  j alias_b
.p2align 9
alias_b:
  j alias_c
.p2align 9
alias_c:
  j alias_return
