.section .text
.globl _start

_start:
    # MMIO base addresses
    li   t0, 0x10000004      # UART_STATUS
    li   t1, 0x10000008      # UART_RXDATA
    li   t2, 0x41            # expected byte 'A'

poll_status:
    lw   t3, 0(t0)           # read status
    addi x0, x0, 0           # nop for load-use timing margin
    addi x0, x0, 0
    addi x0, x0, 0
    andi t3, t3, 0x2         # bit1 = rx_valid
    addi x0, x0, 0           # nop before branch consume
    addi x0, x0, 0
    addi x0, x0, 0
    beq  t3, x0, poll_status

    lw   t4, 0(t1)           # read rxdata (low8 valid)
    addi x0, x0, 0           # nop for load-use timing margin
    addi x0, x0, 0
    addi x0, x0, 0
    andi t4, t4, 0xff
    addi x0, x0, 0           # nop before branch consume
    addi x0, x0, 0
    addi x0, x0, 0
    bne  t4, t2, fail

pass:
    addi x3, x0, 1           # tohost pass
    j    hang

fail:
    addi x3, x0, 2           # tohost fail code

hang:
    j    hang
