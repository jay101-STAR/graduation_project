.section .text
.globl _start

_start:
    # Initialize base address
    li x1, 0x80000000    # Base address for data memory

    # Test 1: Store word at aligned address (offset 0)
    li x2, 0x12345678
    sw x2, 0(x1)

    # Test 2: Load word from aligned address
    lw x3, 0(x1)

    # Test 3: Store word at unaligned address (offset 1)
    li x4, 0xAABBCCDD
    sw x4, 1(x1)

    # Test 4: Load word from unaligned address (offset 1)
    lw x5, 1(x1)

    # Test 5: Store halfword at unaligned address (offset 3)
    li x6, 0x9988
    sh x6, 3(x1)

    # Test 6: Load halfword from unaligned address (offset 3)
    lh x7, 3(x1)

    # Test 7: Store word at unaligned address (offset 2)
    li x8, 0x11223344
    sw x8, 10(x1)

    # Test 8: Load word from unaligned address (offset 2)
    lw x9, 10(x1)

    # Test 9: Store word at unaligned address (offset 3)
    li x10, 0x55667788
    sw x10, 15(x1)

    # Test 10: Load word from unaligned address (offset 3)
    lw x11, 15(x1)

    # Test 11: Load byte from various offsets
    lb x12, 0(x1)
    lb x13, 1(x1)
    lb x14, 2(x1)
    lb x15, 3(x1)

    # Test 12: Store bytes at unaligned positions
    li x16, 0xFF
    sb x16, 20(x1)
    sb x16, 21(x1)
    sb x16, 22(x1)
    sb x16, 23(x1)

    # Test 13: Load word from where we stored bytes
    lw x17, 20(x1)

    # End test - write result to tohost
    li x18, 0x80001000
    li x19, 1
    sw x19, 0(x18)

    # Infinite loop
loop:
    j loop
