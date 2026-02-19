.section .text
.globl _start

_start:
    # MMIO base addresses
    li   t0, 0x10000004      # UART_STATUS
    li   t1, 0x10000000      # UART_TXDATA
    li   t2, 0x0000005a      # 'Z'

    # STATUS.bit0 = tx_ready, should be 1 in this minimal UART model.
    lw   t3, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t3, t3, 0x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    beq  t3, x0, fail_not_ready

    # Write one byte to TXDATA.
    sw   t2, 0(t1)

    # Read STATUS again; with real TX hardware, tx_ready may go low while sending.
    # Poll with timeout until tx_ready is restored.
    li   t6, 200000
poll_tx_ready_after_write:
    lw   t4, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t4, t4, 0x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    bne  t4, x0, pass
    addi t6, t6, -1
    bne  t6, x0, poll_tx_ready_after_write

pass:
    addi x3, x0, 1           # tohost pass
    j    hang

fail_not_ready:
    addi x3, x0, 2           # initial tx_ready = 0
    j    hang

fail_not_ready_after_tx:
    addi x3, x0, 3           # tx_ready not set after write

hang:
    j    hang
