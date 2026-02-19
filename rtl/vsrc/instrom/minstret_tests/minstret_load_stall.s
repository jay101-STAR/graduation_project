.section .text
.globl _start

_start:
    # Warm up pipeline so retire stream reaches steady state.
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    # Prepare one memory word for load-use check.
    li   t6, 0x80002000
    li   a0, 0x12345678
    sw   a0, 0(t6)

    # Self-calibrating load-stall check:
    #   base = (second csrr - first csrr)
    #   measured segment includes:
    #     sub + lw + addi + addi
    csrr t0, 0xB02
    csrr t1, 0xB02
    sub  t2, t1, t0           # base

    lw   t3, 0(t6)
    addi t4, t3, 1
    addi t4, t4, 1
    csrr t5, 0xB02
    sub  t6, t5, t1           # measured

    li   a0, 4
    add  a0, a0, t2           # expected = base + 4
    bne  t6, a0, fail

pass:
    li   t6, 0x80001000
    li   a0, 1
    sw   a0, 0(t6)
1:
    j    1b

fail:
    li   t6, 0x80001000
    li   a0, 2
    sw   a0, 0(t6)
2:
    j    2b
