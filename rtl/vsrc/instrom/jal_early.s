.section .text
.globl _start
.option norvc
.option norelax
_start:
  li x3, 0
  li s3, 0x80005000
  li t0, 100
  sw t0, 0(s3)

  # A target must observe the caller's PC+4 link.
  la s0, returned
  jal ra, function
returned:
  la s0, chain_returned
  jal x5, chain_first
chain_returned:
  # Backward JAL and x0 destination.
  li s1, 3
  j loop_test
loop_body:
  addi s1, s1, -1
loop_test:
  bne s1, x0, loop_jump
  j loop_done
loop_jump:
  j loop_body
loop_done:
  # Older EX branch must squash a younger ID JAL.
  beq x0, x0, branch_wins
  jal ra, fail
branch_wins:
  la t0, jalr_wins
  jalr x0, 0(t0)
  jal ra, fail
jalr_wins:
  # ID JAL must wait while the older multiply/divide is busy.
  li t0, 7
  li t1, 9
  mul t2, t0, t1
  jal ra, after_mul
after_mul:
  li t0, 63
  bne t2, t0, fail
  li t0, 100
  li t1, 3
  div t2, t0, t1
  jal ra, after_div
after_div:
  li t0, 33
  bne t2, t0, fail

  # A load-use stall can leave an old BRAM beat in the front-end buffer.
  lw t0, 0(s3)
  addi t1, t0, 1
  jal ra, after_load
after_load:
  li t0, 101
  bne t1, t0, fail
  # An older trap/mret must win over a younger JAL as well.
  la t0, trap_handler
  csrw mtvec, t0
  la s2, after_ecall
  ecall
  jal ra, fail
after_ecall:
  # FENCE.I flushes this JAL, which must work when fetched again.
  fence.i
  jal ra, after_fence
after_fence:
  lw t0, 0(s3)
  li t1, 100
  bne t0, t1, fail
  li x3, 1
  .rept 8
  nop
  .endr
hang:
  j hang

function:
  bne ra, s0, fail
  jalr x0, 0(ra)
  j fail
chain_first:
  jal x6, chain_second
chain_first_return:
  j fail
chain_second:
  bne x5, s0, fail
  la t3, chain_first_return
  bne x6, t3, fail
  jalr x0, 0(x5)
  j fail
trap_handler:
  csrr t0, mcause
  li t1, 11
  bne t0, t1, fail
  csrw mepc, s2
  mret
  jal ra, fail
fail:
  li x3, 2
  j hang
