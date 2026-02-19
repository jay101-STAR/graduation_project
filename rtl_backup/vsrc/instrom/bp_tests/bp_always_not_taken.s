.section .text
.globl _start

_start:
    # Mostly-not-taken pattern:
    # 16 always-not-taken branches + 1 loop-control branch.
    li t0, 3000

loop_nt:
    bne x0, x0, nt1
nt1:
    bne x0, x0, nt2
nt2:
    bne x0, x0, nt3
nt3:
    bne x0, x0, nt4
nt4:
    bne x0, x0, nt5
nt5:
    bne x0, x0, nt6
nt6:
    bne x0, x0, nt7
nt7:
    bne x0, x0, nt8
nt8:
    bne x0, x0, nt9
nt9:
    bne x0, x0, nt10
nt10:
    bne x0, x0, nt11
nt11:
    bne x0, x0, nt12
nt12:
    bne x0, x0, nt13
nt13:
    bne x0, x0, nt14
nt14:
    bne x0, x0, nt15
nt15:
    bne x0, x0, nt16
nt16:
    addi t0, t0, -1
    bne  t0, x0, loop_nt

pass:
    addi x3,x0,1

hang:
    j hang

