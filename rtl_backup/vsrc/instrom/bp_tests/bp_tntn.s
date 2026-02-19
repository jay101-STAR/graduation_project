.section .text
.globl _start

_start:
    # Alternating taken/not-taken pattern (TNTN...):
    # toggle bit in t1, branch on t1==0.
    li t0, 20000
    addi t1, x0, 0

loop_tntn:
    xori t1, t1, 1
    beq  t1, x0, taken_path
    addi x0, x0, 0
taken_path:
    addi t0, t0, -1
    bne  t0, x0, loop_tntn

pass:
    addi x3,x0,1

hang:
    j hang

