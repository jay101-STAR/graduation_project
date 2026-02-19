.section .text
.globl _start

_start:
    # Two always-taken branches intentionally placed on 512B boundaries.
    # With ENTRY_NUM=128 (index bits [8:2]), these PCs tend to alias
    # to the same direct-mapped BTB/BHT index but with different tags.
    li s0, 4000
    j branch_a

    .p2align 9
branch_a:
    beq x0, x0, a_taken
    addi x0, x0, 0
a_taken:
    addi s0, s0, -1
    beq  s0, x0, pass
    j branch_b

    .p2align 9
branch_b:
    beq x0, x0, b_taken
    addi x0, x0, 0
b_taken:
    j branch_a

pass:
    addi x3,x0,1

hang:
    j hang

