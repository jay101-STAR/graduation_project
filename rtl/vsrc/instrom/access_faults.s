.option norvc
.option norelax
.section .text
.globl _start
_start:
  la t0, trap_handler
  csrw mtvec, t0
  csrsi mstatus, 8
  li t0, 0x2222
  csrw mtval, t0
  li t0, 0x8000ff00
  lw a0, 0(t0)
  li a2, 0x5a5a
  li s4, 0x777
  li s7, 1
  la s3, resume
  li t6, 0x90000000
  li t5, 0x80001008
  li t0, 0
  beq a0, t0, local_load
  li t0, 1
  beq a0, t0, local_store
  li t0, 2
  beq a0, t0, local_fetch
  li t0, 3
  beq a0, t0, bus_load
  li t0, 4
  beq a0, t0, bus_store
  li t0, 5
  beq a0, t0, allocate_store
  li t0, 6
  beq a0, t0, split_load
  li t0, 7
  beq a0, t0, split_store
  li t0, 8
  beq a0, t0, kill_csr
  li t0, 9
  beq a0, t0, kill_ecall
  li t0, 10
  beq a0, t0, kill_jump
  li t0, 11
  beq a0, t0, wrong_path
  li t0, 12
  beq a0, t0, bus_fetch
  li t0, 13
  beq a0, t0, load_x0
  li t0, 14
  beq a0, t0, kill_div
  li t0, 15
  beq a0, t0, kill_mul
  li t0, 16
  beq a0, t0, ram_boundary
  li t0, 17
  beq a0, t0, wrong_path_local
  li t0, 18
  beq a0, t0, older_store
  li t0, 19
  beq a0, t0, misaligned_jalr
  li t0, 20
  beq a0, t0, misaligned_jal
  li t0, 21
  beq a0, t0, misaligned_branch
  li t0, 22
  beq a0, t0, writeback_load
  li t0, 23
  beq a0, t0, writeback_store
  j fail

local_load:
  li s0, 5
  li t1, 0x90000000
  mv s2, t1
  la s1, local_load_pc
  csrr s8, minstret
local_load_pc:
  lw a2, 0(t1)
  sw s4, 0(t5)
  j poison
local_store:
  li s0, 7
  li t1, 0x90000000
  mv s2, t1
  la s1, local_store_pc
  csrr s8, minstret
local_store_pc:
  sw a2, 0(t1)
  j poison
local_fetch:
  li s0, 1
  li s7, 2
  li t1, 0x90000000
  mv s1, t1
  mv s2, t1
  csrr s8, minstret
  jr t1
  j poison
bus_load:
  li s0, 5
  li t1, 0x80003008
  mv s2, t1
  la s1, bus_load_pc
  csrr s8, minstret
bus_load_pc:
  lw a2, 0(t1)
  j poison
bus_store:
  li s0, 7
  li t1, 0x10000004
  mv s2, t1
  la s1, bus_store_pc
  csrr s8, minstret
bus_store_pc:
  sw a2, 0(t1)
  j poison
allocate_store:
  li s0, 7
  li t1, 0x80003008
  mv s2, t1
  la s1, allocate_store_pc
  csrr s8, minstret
allocate_store_pc:
  sw a2, 0(t1)
  j poison
split_load:
  li s0, 5
  li t1, 0x80002fff
  li s2, 0x80003000
  la s1, split_load_pc
  csrr s8, minstret
split_load_pc:
  lw a2, 0(t1)
  j poison
split_store:
  li s0, 7
  li t1, 0x80002fff
  li t2, 0x11223344
  li s2, 0x80003000
  la s1, split_store_pc
  csrr s8, minstret
split_store_pc:
  sw t2, 0(t1)
  j poison
kill_csr:
  li s0, 5
  li t1, 0x80003008
  mv s2, t1
  la s1, kill_csr_pc
  csrr s8, minstret
kill_csr_pc:
  lw a2, 0(t1)
  csrw mtvec, t6
  j poison
kill_ecall:
  li s0, 5
  li t1, 0x80003008
  mv s2, t1
  la s1, kill_ecall_pc
  csrr s8, minstret
kill_ecall_pc:
  lw a2, 0(t1)
  ecall
  j poison
kill_jump:
  li s0, 5
  li t1, 0x80003008
  mv s2, t1
  la s1, kill_jump_pc
  csrr s8, minstret
kill_jump_pc:
  lw a2, 0(t1)
  j poison
load_x0:
  li s0, 5
  li t1, 0x80003008
  mv s2, t1
  la s1, load_x0_pc
  csrr s8, minstret
load_x0_pc:
  lw x0, 0(t1)
  j poison
kill_div:
  li s0, 5
  li t1, 0x80003008
  mv s2, t1
  la s1, kill_div_pc
  csrr s8, minstret
kill_div_pc:
  lw a2, 0(t1)
  div s4, a2, a2
  j poison
kill_mul:
  li s0, 5
  li t1, 0x80003008
  mv s2, t1
  la s1, kill_mul_pc
  csrr s8, minstret
kill_mul_pc:
  lw a2, 0(t1)
  mul s4, a2, a2
  j poison
ram_boundary:
  li s0, 7
  li t1, 0x8000ffff
  li s2, 0x80010000
  la s1, ram_boundary_pc
  csrr s8, minstret
ram_boundary_pc:
  sw a2, 0(t1)
  j poison
bus_fetch:
  li s0, 1
  li s7, 2
  li t1, 0x8000d000
  mv s1, t1
  mv s2, t1
  csrr s8, minstret
  jr t1
  j poison
wrong_path:
  li s0, 0
  j branch_line
.balign 64
branch_line:
  .rept 15
  nop
  .endr
  beq x0, x0, branch_ok
.globl wrong_path_pc
wrong_path_pc:
  j poison
.balign 64
branch_ok:
  j resume
wrong_path_local:
  li s0, 0
  li t1, 0x8000fffc
  jr t1
older_store:
  li s0, 1
  li s7, 18
  li t1, 0x80001004
  li t2, 0x76543210
  li t0, 0x8000e000
  li s1, 0x8000e040
  mv s2, s1
  csrr s8, minstret
  jr t0

misaligned_jalr:
  li s0, 0
  li t1, 0x80002002
  mv s2, t1
  la s1, misaligned_jalr_pc
  csrr s8, minstret
misaligned_jalr_pc:
  jalr s4, 0(t1)
  j poison
misaligned_jal:
  li s0, 0
  la s1, misaligned_jal_pc
  addi s2, s1, 2
  csrr s8, minstret
misaligned_jal_pc:
  jal s4, misaligned_jal_pc+2
  j poison
misaligned_branch:
  li s0, 0
  la s1, misaligned_branch_pc
  addi s2, s1, 2
  csrr s8, minstret
misaligned_branch_pc:
  beq x0, x0, misaligned_branch_pc+2
  j poison

writeback_load:
  li s0, 5
  la s1, writeback_load_pc
  j dirty_ways
writeback_store:
  li s0, 7
  la s1, writeback_store_pc
dirty_ways:
  li t1, 0x80002008
  li t2, 0x12340000
  sw t2, 0(t1)
  li t1, 0x80004008
  addi t2, t2, 1
  sw t2, 0(t1)
  li t1, 0x80006008
  addi t2, t2, 1
  sw t2, 0(t1)
  li t1, 0x80008008
  addi t2, t2, 1
  sw t2, 0(t1)
  li t1, 0x8000a008
  mv s2, t1
  li t0, 22
  bne a0, t0, do_writeback_store
  csrr s8, minstret
writeback_load_pc:
  lw a2, 0(t1)
  j poison
do_writeback_store:
  csrr s8, minstret
writeback_store_pc:
  sw a2, 0(t1)
  j poison

poison:
  li s4, 0x999
  li t0, 0x80001008
  sw s4, 0(t0)
  j fail

trap_handler:
  csrr s10, minstret
  add t0, s8, s7
  bne s10, t0, fail
  csrr t0, mcause
  bne t0, s0, fail
  csrr t0, mepc
  bne t0, s1, fail
  csrr t0, mtval
  bne t0, s2, fail
  csrr t0, mstatus
  andi t1, t0, 8
  bnez t1, fail
  andi t0, t0, 128
  beqz t0, fail
  li t0, 0x5a5a
  bne a2, t0, fail
  li t0, 0x777
  bne s4, t0, fail
  csrw mepc, s3
  mret
resume:
  li t0, 0x777
  bne s4, t0, fail
  li t0, 0x5a5a
  bne a2, t0, fail
  li t0, 0x80001008
  lw t1, 0(t0)
  bnez t1, fail
  csrr t0, mstatus
  andi t0, t0, 8
  beqz t0, fail
  # A handler must be able to use fresh MUL/DIV after killing a younger unit.
  li t0, 6
  li t1, 3
  div t2, t0, t1
  li t3, 2
  bne t2, t3, fail
  mul t2, t0, t1
  li t3, 18
  bne t2, t3, fail
  li t0, 7
  bne a0, t0, check_writeback
  li t0, 0x80002fff
  lbu t1, 0(t0)
  li t2, 0x44
  bne t1, t2, fail
check_writeback:
  li t0, 22
  blt a0, t0, check_older_store
  li t0, 0x80002008
  lw t1, 0(t0)
  li t2, 0x12340000
  bne t1, t2, fail
check_older_store:
  li t0, 18
  bne a0, t0, pass
  li t0, 0x80001004
  lw t1, 0(t0)
  li t2, 0x76543210
  bne t1, t2, fail
pass:
  li t0, 0x80001000
  li t1, 1
  sw t1, 0(t0)
1: j 1b
fail:
  li t0, 0x80001000
  li t1, 3
  sw t1, 0(t0)
2: j 2b

.org 0xd000
  j poison
.org 0xe000
  .rept 15
  nop
  .endr
  sw t2, 0(t1)
  j poison
.org 0xfc00
boundary_return:
  jr s3
.org 0xfffc
  beq x0, x0, boundary_return
