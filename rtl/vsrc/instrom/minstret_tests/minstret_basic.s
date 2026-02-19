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

    # Self-calibrating check:
    #   base = (second csrr - first csrr)
    #   measured segment includes:
    #     sub + 4 arithmetic instructions
    #   target = base + 5
    csrr t0, 0xB02
    csrr t1, 0xB02
    sub  t2, t1, t0           # base

    addi t3, x0, 1
    addi t3, t3, 2
    add  t3, t3, t3
    addi t3, t3, 5

    csrr t4, 0xB02
    sub  t5, t4, t1           # measured

    li   t6, 5
    add  t6, t6, t2           # expected = base + 5
    bne  t5, t6, fail

pass:
    li   t5, 0x80001000
    li   t6, 1
    sw   t6, 0(t5)
1:
    j    1b

fail:
    li   t5, 0x80001000
    li   t6, 2
    sw   t6, 0(t5)
2:
    j    2b
