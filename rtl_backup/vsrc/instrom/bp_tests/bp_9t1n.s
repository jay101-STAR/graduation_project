.section .text
.globl _start

_start:
    # 9 taken, 1 not-taken repeating pattern on one branch.
    # bne t1,t2,mostly_taken  => taken for t1=1..9, not-taken for t1=10
    li t0, 20000
    addi t1, x0, 0
    li t2, 10

loop_9t1n:
    addi t1, t1, 1
    bne  t1, t2, mostly_taken
    addi t1, x0, 0

mostly_taken:
    addi t0, t0, -1
    bne  t0, x0, loop_9t1n

pass:
    addi x3,x0,1

hang:
    j hang

