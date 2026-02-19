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

    # Self-calibrating flush check:
    #   base = (second csrr - first csrr)
    #   measured segment includes:
    #     sub + jal + addi + addi
    #   wrong-path addi should be flushed and not retired
    csrr t0, 0xB02
    csrr t1, 0xB02
    sub  t2, t1, t0           # base

    jal  x0, after_jump
    addi t3, x0, 0x55         # Wrong-path instruction, should be flushed.

after_jump:
    addi t4, x0, 7
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
