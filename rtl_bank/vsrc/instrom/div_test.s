.section .text
.globl _start

_start:
    # Test 1: Simple signed division: 20 / 3 = 6, remainder 2
    li x1, 20
    li x2, 3
    div x3, x1, x2      # x3 = 6
    rem x4, x1, x2      # x4 = 2

    # Test 2: Unsigned division: 20 / 3 = 6, remainder 2
    li x5, 20
    li x6, 3
    divu x7, x5, x6     # x7 = 6
    remu x8, x5, x6     # x8 = 2

    # Test 3: Negative dividend: -20 / 3 = -6, remainder -2
    li x9, -20
    li x10, 3
    div x11, x9, x10    # x11 = -6
    rem x12, x9, x10    # x12 = -2

    # Test 4: Negative divisor: 20 / -3 = -6, remainder 2
    li x13, 20
    li x14, -3
    div x15, x13, x14   # x15 = -6
    rem x16, x13, x14   # x16 = 2

    # Test 5: Both negative: -20 / -3 = 6, remainder -2
    li x17, -20
    li x18, -3
    div x19, x17, x18   # x19 = 6
    rem x20, x17, x18   # x20 = -2

    # Test 6: Division by zero (should return -1 for quotient, dividend for remainder)
    li x21, 100
    li x22, 0
    div x23, x21, x22   # x23 = -1 (0xFFFFFFFF)
    rem x24, x21, x22   # x24 = 100

    # Test 7: Overflow case: 0x80000000 / -1 (should return 0x80000000, remainder 0)
    lui x25, 0x80000
    li x26, -1
    div x27, x25, x26   # x27 = 0x80000000
    rem x28, x25, x26   # x28 = 0

    # Write test completion marker to tohost
    li x29, 1
    lui x30, 0x80001
    sw x29, 0(x30)      # Write 1 to 0x80001000 (tohost)

    # Infinite loop
loop:
    j loop
