.section .text
.globl _start

_start:
    # MMIO base addresses
    li   t0, 0x10000004      # UART_STATUS
    li   t1, 0x10000000      # UART_TXDATA
    li   t2, 0x10000008      # UART_RXDATA

echo_wait_rx:
    # Wait until rx_valid (bit1) is set.
    lw   t3, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t3, t3, 0x2
    beq  t3, x0, echo_wait_rx

    # Pop one byte from RXDATA.
    lw   t4, 0(t2)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

echo_wait_tx:
    # Wait until tx_ready (bit0) is set.
    lw   t5, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t5, t5, 0x1
    beq  t5, x0, echo_wait_tx

    # Write back the received byte.
    sw   t4, 0(t1)
    j    echo_wait_rx
