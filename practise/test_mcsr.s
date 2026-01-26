# ============================================
# Quick Unaligned Memory Access Test
# Simplified test for fast verification
# ============================================

.section .text
.globl _start

_start:
    # Initialize test tracking
    addi    x10, x0, 0          # x10 = test progress counter
    addi    x11, x0, 0          # x11 = error counter
    li      x1, 0x80000000      # x1 = base address

    # ========================================
    # Test 1: Word unaligned at offset 1
    # ========================================
    addi    x10, x10, 1
    li      x2, 0x11223344
    lw      x3, 0(x1)          # Read unaligned at 0x80000001

    sw      x2, 0(x1)          # Write aligned at 0x80000000
    # Expected: x3 = 0x44000000 (little endian)
    li      x4, 0x44
    slli    x4, x4, 24          # x4 = 0x44000000
    beq     x3, x4, test1_pass
    addi    x11, x11, 1
test1_pass:

    # ========================================
    # Test 2: Word unaligned at offset 2
    # ========================================
    addi    x10, x10, 1
    li      x2, 0x55667788
    sw      x2, 4(x1)          # Write aligned at 0x80000004
    lw      x5, 6(x1)          # Read unaligned at 0x80000006
    # Expected: x5 = 0x77880000
    li      x4, 0x7788
    slli    x4, x4, 16          # x4 = 0x77880000
    beq     x5, x4, test2_pass
    addi    x11, x11, 1
test2_pass:

    # ========================================
    # Test 3: Word unaligned at offset 3
    # ========================================
    addi    x10, x10, 1
    li      x2, 0x99AABBCC
    sw      x2, 8(x1)          # Write aligned at 0x80000008
    lw      x6, 11(x1)         # Read unaligned at 0x8000000b
    # Expected: x6 = 0x00000000
    li      x4, 0
    beq     x6, x4, test3_pass
    addi    x11, x11, 1
test3_pass:

    # ========================================
    # Test 4: Halfword unaligned at offset 1
    # ========================================
    addi    x10, x10, 1
    li      x7, 0xCAFE
    sh      x7, 16(x1)         # Write halfword at 0x80000010
    lh      x8, 17(x1)         # Read halfword at 0x80000011 (unaligned)
    # Expected: x8 = 0xFFFFFE00 (sign-extended)
    li      x4, 0xFFFFFE00
    beq     x8, x4, test4_pass
    addi    x11, x11, 1
test4_pass:

    # ========================================
    # Test 5: Halfword unsigned unaligned
    # ========================================
    addi    x10, x10, 1
    lhu     x9, 17(x1)         # Read halfword unsigned at 0x80000011
    # Expected: x9 = 0x0000FE00 (zero-extended)
    li      x4, 0x0000FE00
    beq     x9, x4, test5_pass
    addi    x11, x11, 1
test5_pass:

    # ========================================
    # Test 6: Byte sign extension
    # ========================================
    addi    x10, x10, 1
    li      x10, 0xFF
    sb      x10, 32(x1)        # Write byte at 0x80000020
    lb      x11, 32(x1)        # Read byte sign-extended
    # Expected: x11 = 0xFFFFFFFF
    li      x4, 0xFFFFFFFF
    beq     x11, x4, test6_pass
    addi    x11, x11, 1
test6_pass:
    addi    x10, x10, 1        # Restore test counter

    # ========================================
    # Test 7: Overlapping unaligned write
    # ========================================
    addi    x10, x10, 1
    li      x12, 0x11111111
    sw      x12, 64(x1)        # Write 0x11111111 at 0x80000040

    li      x13, 0x22222222
    sw      x13, 66(x1)        # Overlap with offset 2 (unaligned)

    lw      x14, 64(x1)        # Read at 0x80000040
    # Expected: x14 = 0x11222222
    li      x4, 0x11222222
    beq     x14, x4, test7_pass
    addi    x11, x11, 1
test7_pass:

    # ========================================
    # Success: Write 1 to tohost
    # ========================================
    beq     x11, x0, success     # No errors?

    # Test failed
    li      x1, 0x80001000
    slli    x11, x11, 1
    sw      x11, 0(x1)          # Write error code
    j       end

success:
    li      x1, 0x80001000
    li      x2, 1
    sw      x2, 0(x1)           # Write success

end:
    j       end


