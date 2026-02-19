.section .text
.globl _start

_start:
    # Mostly-taken single branch pattern:
    # bne is taken until the last iteration.
    li t0, 20000

loop_taken:
    addi t0, t0, -1
    bne  t0, x0, loop_taken

pass:
    addi x3,x0,1

hang:
    j hang

