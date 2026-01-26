.section .text
.globl _start

_start:
    # Initialize base address
    li x1, 0x80000000

    # Test Case 1: Write and read back at all 4 byte offsets for word
    li x2, 0xDEADBEEF

    # Offset 0 (aligned)
    sw x2, 0(x1)
    lw x3, 0(x1)

    # Offset 1
    sw x2, 4(x1)
    lw x4, 4(x1)

    # Offset 2
    sw x2, 8(x1)
    lw x5, 8(x1)

    # Offset 3
    sw x2, 12(x1)
    lw x6, 12(x1)

    # Test Case 2: Halfword at all offsets
    li x7, 0xCAFE

    # Offset 0
    sh x7, 16(x1)
    lh x8, 16(x1)
    lhu x9, 16(x1)

    # Offset 1
    sh x7, 21(x1)
    lh x10, 21(x1)
    lhu x11, 21(x1)

    # Offset 2
    sh x7, 26(x1)
    lh x12, 26(x1)
    lhu x13, 26(x1)

    # Offset 3
    sh x7, 31(x1)
    lh x14, 31(x1)
    lhu x15, 31(x1)

    # Test Case 3: Overlapping writes
    li x16, 0x11111111
    sw x16, 40(x1)

    li x17, 0x22222222
    sw x17, 42(x1)  # Overlaps with previous write

    lw x18, 40(x1)
    lw x19, 42(x1)
    lw x20, 44(x1)

    # Test Case 4: Byte operations at unaligned word boundaries
    li x21, 0xAA
    sb x21, 50(x1)
    sb x21, 51(x1)
    sb x21, 52(x1)
    sb x21, 53(x1)

    lw x22, 50(x1)  # Should read 0xAAAAAAAA

    # Test Case 5: Sign extension test
    li x23, 0xFF
    sb x23, 60(x1)
    lb x24, 60(x1)   # Should be sign-extended to 0xFFFFFFFF
    lbu x25, 60(x1)  # Should be zero-extended to 0x000000FF

    # Success - write to tohost
    li x26, 0x80001000
    li x27, 1
    sw x27, 0(x26)

loop:
    j loop
