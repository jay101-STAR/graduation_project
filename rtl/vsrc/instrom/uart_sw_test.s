.section .text
.globl _start

_start:
    # UART MMIO 地址
    lui  x10, 0x10000          # x10 = 0x10000000, UART_TXDATA
    addi x12, x10, 4           # x12 = 0x10000004, UART_STATUS

    # 待发送数据：ASCII 'U'，UART 使用写数据低 8 位
    addi x11, x0, 0x55         # x11 = 0x00000055

    # 发送前检查 UART 是否 ready
    lw   x13, 0(x12)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi x13, x13, 0x1
    beq  x13, x0, fail_not_ready

    # 被测指令：向 UART_TXDATA 写入 x11
    sw   x11, 0(x10)

    # 写入后应观察到 tx_ready 拉低，表示 UART 已接收发送请求
    li   x14, 200000
wait_tx_busy:
    lw   x13, 0(x12)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi x13, x13, 0x1
    beq  x13, x0, wait_tx_ready
    addi x14, x14, -1
    bne  x14, x0, wait_tx_busy
    addi x15, x0, 3           # 未观察到 busy
    j    write_tohost

    # 等待发送完成，tx_ready 重新变为 1
wait_tx_ready:
    li   x14, 200000
poll_tx_ready:
    lw   x13, 0(x12)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    andi x13, x13, 0x1
    bne  x13, x0, pass
    addi x14, x14, -1
    bne  x14, x0, poll_tx_ready
    addi x15, x0, 4           # busy 后未恢复 ready
    j    write_tohost

pass:
    addi x15, x0, 1           # tohost = 1 表示通过
    j    write_tohost

fail_not_ready:
    addi x15, x0, 2           # 初始 tx_ready = 0

write_tohost:
    lui  x16, 0x80001         # x16 = 0x80001000
    sw   x15, 0(x16)

hang:
    j    hang
