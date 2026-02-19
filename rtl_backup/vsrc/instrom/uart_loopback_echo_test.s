.section .text
.globl _start

_start:
    # MMIO base addresses
    li   t0, 0x10000004      # UART_STATUS
    li   t1, 0x10000000      # UART_TXDATA
    li   t2, 0x10000008      # UART_RXDATA
    li   t3, 0x4b            # expected byte 'K'

    # Wait tx_ready(bit0)=1 before TX write
    li   t6, 200000
wait_tx_ready:
    lw   t4, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t5, t4, 0x1
    bne  t5, x0, do_tx
    addi t6, t6, -1
    bne  t6, x0, wait_tx_ready
    j    fail_tx_not_ready

do_tx:
    sw   t3, 0(t1)

    # Wait rx_valid(bit1)=1 for loopback byte arrival
    li   t6, 300000
wait_rx_valid:
    lw   t4, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t5, t4, 0x2
    bne  t5, x0, read_rx
    addi t6, t6, -1
    bne  t6, x0, wait_rx_valid
    j    fail_rx_timeout

read_rx:
    lw   s0, 0(t2)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi s0, s0, 0xff
    bne  s0, t3, fail_data_mismatch

    # After RXDATA pop, rx_valid should clear for single-byte loopback
    lw   s1, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi s1, s1, 0x2
    bne  s1, x0, fail_rx_not_cleared

pass:
    addi x3, x0, 1           # tohost pass
    j    hang

fail_tx_not_ready:
    addi x3, x0, 2           # tx_ready timeout
    j    hang

fail_rx_timeout:
    addi x3, x0, 3           # rx_valid timeout
    j    hang

fail_data_mismatch:
    addi x3, x0, 4           # loopback data mismatch
    j    hang

fail_rx_not_cleared:
    addi x3, x0, 5           # rx_valid not cleared after pop
    j    hang

hang:
    j    hang
