# ============================================
# Comprehensive Unaligned Memory Access Test
# Tests S_TYPE (store) and L_TYPE (load) instructions
# for unaligned addresses at all byte offsets
# ============================================

.section .text
.globl _start

_start:
    # Initialize test tracking register
    addi    x10, x0, 0          # x10 = test progress counter (0 = start)
    addi    x11, x0, 0          # x11 = error counter

    # Initialize base address for data memory
    li      x1, 0x80000000      # x1 = base address for test data

    # ========================================
    # Test Suite 1: Word (32-bit) Unaligned Access
    # ========================================
    addi    x10, x10, 1         # Test 1: SW/LW at offset 0 (aligned - baseline)
    li      x2, 0xDEADBEEF
    sw      x2, 0(x1)
    lw      x3, 0(x1)
    beq     x2, x3, test1_pass
    addi    x11, x11, 1         # Error counter increment
test1_pass:

    addi    x10, x10, 1         # Test 2: SW/LW at offset 1 (unaligned)
    li      x2, 0x11223344
    sw      x2, 4(x1)           # Write at offset 4 (aligned)
    lw      x4, 5(x1)           # Read at offset 5 (unaligned)
    # Expected: x4 = 0x44XXXXXX (bytes from x2 shifted)
    addi    x2, x0, 0x44
    slli    x2, x2, 24          # x2 = 0x44000000
    beq     x4, x2, test2_pass
    addi    x11, x11, 1
test2_pass:

    addi    x10, x10, 1         # Test 3: SW/LW at offset 2 (unaligned)
    li      x2, 0x55667788
    sw      x2, 8(x1)           # Write at offset 8 (aligned)
    lw      x5, 10(x1)          # Read at offset 10 (unaligned)
    # Expected: x5 = 0x7788XXXX
    addi    x2, x0, 0x7788
    slli    x2, x2, 16          # x2 = 0x77880000
    beq     x5, x2, test3_pass
    addi    x11, x11, 1
test3_pass:

    addi    x10, x10, 1         # Test 4: SW/LW at offset 3 (unaligned)
    li      x2, 0x99AABBCC
    sw      x2, 12(x1)          # Write at offset 12 (aligned)
    lw      x6, 15(x1)          # Read at offset 15 (unaligned)
    # Expected: x6 = 0x000000CC
    addi    x2, x0, 0xCC        # x2 = 0x000000CC
    beq     x6, x2, test4_pass
    addi    x11, x11, 1
test4_pass:

    # ========================================
    # Test Suite 2: Halfword (16-bit) Unaligned Access
    # ========================================
    addi    x10, x10, 1         # Test 5: SH/LH at offset 0 (aligned - baseline)
    li      x7, 0xCAFE
    sh      x7, 16(x1)
    lh      x8, 16(x1)
    # Expected: x8 = 0xFFFFCAFE (sign-extended)
    li      x2, 0xFFFFCAFE
    beq     x8, x2, test5_pass
    addi    x11, x11, 1
test5_pass:

    addi    x10, x10, 1         # Test 6: SH/LHU at offset 0 (zero-extended)
    lhu     x9, 16(x1)
    li      x2, 0x0000CAFE
    beq     x9, x2, test6_pass
    addi    x11, x11, 1
test6_pass:

    addi    x10, x10, 1         # Test 7: SH/LH at offset 1 (unaligned)
    li      x7, 0xDEAD
    sh      x7, 21(x1)          # Write at offset 21 (odd offset)
    lh      x10, 21(x1)         # Read at offset 21 (odd offset)
    # Expected: x10 = 0xFFFFAD00 (bytes: 0xAD, 0x00)
    li      x2, 0xFFFFAD00
    beq     x10, x2, test7_pass
    addi    x11, x11, 1
test7_pass:

    addi    x10, x10, 1         # Test 8: SH/LHU at offset 1 (zero-extended)
    lhu     x11, 21(x1)
    li      x2, 0x0000AD00
    beq     x11, x2, test8_pass
    addi    x11, x11, 1
test8_pass:

    addi    x10, x10, 1         # Test 9: SH/LH at offset 3 (unaligned)
    li      x7, 0xBEEF
    sh      x7, 31(x1)          # Write at offset 31 (odd offset)
    lh      x12, 31(x1)         # Read at offset 31 (odd offset)
    # Expected: x12 = 0xFFFF00EF (bytes: 0x00, 0xEF)
    li      x2, 0xFFFF00EF
    beq     x12, x2, test9_pass
    addi    x11, x11, 1
test9_pass:

    # ========================================
    # Test Suite 3: Byte Access (No alignment requirement)
    # ========================================
    addi    x10, x10, 1         # Test 10: SB/LB sign extension
    li      x13, 0xFF
    sb      x13, 60(x1)
    lb      x14, 60(x1)         # Should be sign-extended to 0xFFFFFFFF
    li      x2, 0xFFFFFFFF
    beq     x14, x2, test10_pass
    addi    x11, x11, 1
test10_pass:

    addi    x10, x10, 1         # Test 11: SB/LBU zero extension
    lbu     x15, 60(x1)         # Should be zero-extended to 0x000000FF
    li      x2, 0x000000FF
    beq     x15, x2, test11_pass
    addi    x11, x11, 1
test11_pass:

    # ========================================
    # Test Suite 4: Overlapping Unaligned Writes
    # ========================================
    addi    x10, x10, 1         # Test 12: Overlapping word writes
    li      x16, 0x11111111
    sw      x16, 40(x1)         # Write word at aligned address

    li      x17, 0x22222222
    sw      x17, 42(x1)         # Overlapping unaligned write (offset 2)

    lw      x18, 40(x1)         # Read at offset 40
    # Expected: x18 = 0x11222222 (overlap zone updated)
    li      x2, 0x11222222
    beq     x18, x2, test12_pass
    addi    x11, x11, 1
test12_pass:

    addi    x10, x10, 1         # Test 13: Verify overlapping write at offset 42
    lw      x19, 42(x1)
    # Expected: x19 = 0x2222XXXX
    li      x2, 0x2222
    slli    x2, x2, 16
    beq     x19, x2, test13_pass
    addi    x11, x11, 1
test13_pass:

    addi    x10, x10, 1         # Test 14: Verify overlapping write at offset 44
    lw      x20, 44(x1)
    # Expected: x20 = 0x22221111
    li      x2, 0x22221111
    beq     x20, x2, test14_pass
    addi    x11, x11, 1
test14_pass:

    # ========================================
    # Test Suite 5: Mixed Size Operations
    # ========================================
    addi    x10, x10, 1         # Test 15: Store bytes, read as word
    li      x21, 0xAA
    sb      x21, 50(x1)
    sb      x21, 51(x1)
    sb      x21, 52(x1)
    sb      x21, 53(x1)

    lw      x22, 50(x1)         # Should read 0xAAAAAAAA
    li      x2, 0xAAAAAAAA
    beq     x22, x2, test15_pass
    addi    x11, x11, 1
test15_pass:

    addi    x10, x10, 1         # Test 16: Store word, read as bytes
    li      x23, 0x12345678
    sw      x23, 64(x1)

    lb      x24, 64(x1)         # Should be 0x78 (little endian)
    lb      x25, 65(x1)         # Should be 0x56
    lb      x26, 66(x1)         # Should be 0x34
    lb      x27, 67(x1)         # Should be 0x12

    li      x2, 0x78
    beq     x24, x2, test16_pass
    addi    x11, x11, 1
test16_pass:

    li      x2, 0x56
    beq     x25, x2, test16a_pass
    addi    x11, x11, 1
test16a_pass:

    li      x2, 0x34
    beq     x26, x2, test16b_pass
    addi    x11, x11, 1
test16b_pass:

    li      x2, 0x12
    beq     x27, x2, test16c_pass
    addi    x11, x11, 1
test16c_pass:

    # ========================================
    # Test Suite 6: All Byte Offsets for Word Access
    # ========================================
    addi    x10, x10, 1         # Test 17: Word write/read at all 4 offsets
    li      x2, 0x00AABBCC

    # Offset 0 (aligned)
    sw      x2, 80(x1)
    lw      x3, 80(x1)
    beq     x2, x3, test17_0_pass
    addi    x11, x11, 1
test17_0_pass:

    # Offset 1
    lw      x4, 81(x1)
    # Expected: 0x00AABBCC >> 8 = 0x0000AABB
    srli    x5, x2, 8
    beq     x4, x5, test17_1_pass
    addi    x11, x11, 1
test17_1_pass:

    # Offset 2
    lw      x6, 82(x1)
    # Expected: 0x00AABBCC >> 16 = 0x000000AA
    srli    x7, x2, 16
    beq     x6, x7, test17_2_pass
    addi    x11, x11, 1
test17_2_pass:

    # Offset 3
    lw      x8, 83(x1)
    # Expected: 0x00AABBCC >> 24 = 0x00000000
    srli    x9, x2, 24
    beq     x8, x9, test17_3_pass
    addi    x11, x11, 1
test17_3_pass:

    # ========================================
    # Final Check: All tests passed?
    # ========================================
    beq     x11, x0, success     # If error counter is 0, all tests passed

    # Test failed - write error code to tohost
    li      x1, 0x80001000
    slli    x11, x11, 1          # Shift left by 1 (error code format)
    sw      x11, 0(x1)
    j       end

success:
    # All tests passed - write 1 to tohost
    li      x1, 0x80001000
    li      x2, 1
    sw      x2, 0(x1)

end:
    # Infinite loop
    j       end
