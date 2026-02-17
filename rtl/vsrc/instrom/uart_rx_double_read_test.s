.section .text
.globl _start

_start:
    # MMIO base addresses
    li   t0, 0x10000004      # UART_STATUS
    li   t1, 0x10000008      # UART_RXDATA
    li   t2, 0x41            # expected byte 'A'

poll_status_1:
    lw   t3, 0(t0)           # read status
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t3, t3, 0x2         # bit1 = rx_valid
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    beq  t3, x0, poll_status_1

    # First read: must get injected byte 0x41
    lw   t4, 0(t1)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t4, t4, 0xff
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    bne  t4, t2, fail_first_data

    # Second status read: rx_valid should be cleared after RXDATA read
    lw   t5, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t5, t5, 0x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    bne  t5, x0, fail_rxvalid_not_cleared

pass:
    addi x3, x0, 1           # tohost pass
    j    hang

fail_first_data:
    addi x3, x0, 2           # first data mismatch
    j    hang

fail_rxvalid_not_cleared:
    addi x3, x0, 3           # second status still valid

hang:
    j    hang

