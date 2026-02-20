.section .text
.globl _start

_start:
    # MMIO base addresses
    li   t0, 0x10000004      # UART_STATUS
    li   t1, 0x10000008      # UART_RXDATA
    li   t2, 0x41            # expected first byte 'A'

    # Board-interactive mode:
    # wait forever until at least one RX byte arrives (bit1=rx_valid).
poll_status_valid:
    lw   t3, 0(t0)           # read status
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t3, t3, 0x2         # bit1 = rx_valid
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    beq  t3, x0, poll_status_valid

    # Board-friendly overrun detection:
    # keep polling until bit2 sets, instead of checking exactly once.
wait_overrun_set:
    lw   t4, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t4, t4, 0x4
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    beq  t4, x0, wait_overrun_set

check_first_rx_byte:
    # RXDATA should still return first unread byte in this minimal model.
    lw   t5, 0(t1)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t5, t5, 0xff
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    bne  t5, t2, fail_data_mismatch

    # FIFO model: after one pop, overrun clears but rx_valid should remain 1 (more data pending).
    lw   t6, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t6, t6, 0x6         # bit2|bit1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    li   s0, 0x2             # expect bit1=1, bit2=0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    bne  t6, s0, fail_status_after_pop

pass:
    addi x3, x0, 1           # tohost pass
    j    hang

fail_overrun_not_set:
    addi x3, x0, 2           # bit2 not set
    j    hang

fail_data_mismatch:
    addi x3, x0, 3           # RXDATA mismatch
    j    hang

fail_status_after_pop:
    addi x3, x0, 4           # unexpected status after first RXDATA pop

hang:
    j    hang
