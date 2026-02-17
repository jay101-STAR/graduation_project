.section .text
.globl _start

_start:
    # MMIO base addresses
    li   t0, 0x10000004      # UART_STATUS
    li   t1, 0x10000000      # UART_TXDATA
    li   s0, 0x41            # first byte 'A'
    li   s1, 4               # send 4 bytes: A,B,C,D

send_next_byte:
    # Wait tx_ready(bit0)=1 before write
    li   t6, 200000
wait_ready_before:
    lw   t3, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t3, t3, 0x1
    bne  t3, x0, do_write
    addi t6, t6, -1
    bne  t6, x0, wait_ready_before
    j    fail_ready_before

do_write:
    sw   s0, 0(t1)
    addi s0, s0, 1

    # Wait tx_ready recovers after this byte is accepted
    li   t6, 200000
wait_ready_after:
    lw   t4, 0(t0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi t4, t4, 0x1
    bne  t4, x0, one_done
    addi t6, t6, -1
    bne  t6, x0, wait_ready_after
    j    fail_ready_after

one_done:
    addi s1, s1, -1
    bne  s1, x0, send_next_byte

pass:
    addi x3, x0, 1           # tohost pass
    j    hang

fail_ready_before:
    addi x3, x0, 2           # tx_ready did not assert before write
    j    hang

fail_ready_after:
    addi x3, x0, 3           # tx_ready did not recover
    j    hang

hang:
    j    hang
