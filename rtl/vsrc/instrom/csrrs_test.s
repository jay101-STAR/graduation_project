.text
.global _start

_start:
    # Test CSRRS (Control and Status Register Read and Set) instruction
    # CSRRS reads a CSR value into rd and sets bits in CSR based on rs

    # First, let's test with some basic CSRs

    # Test 1: Read and set bits in mcycle (0xB00)
    # mcycle is a counter that increments every cycle
    li x1, 0x0000000F          # Load pattern to set lower 4 bits
    csrrs x2, 0xB00, x1        # Read mcycle into x2, set bits based on x1
    # x2 now contains original mcycle value
    # mcycle now has bits 0-3 set (if they weren't already)

    # Test 2: Read and set bits in mstatus (0x300)
    # mstatus has various mode and interrupt enable bits
    li x3, 0x00000008          # Load value to set bit 3 (MIE - Machine Interrupt Enable)
    csrrs x4, 0x300, x3        # Read mstatus into x4, set MIE bit
    # x4 contains original mstatus value
    # mstatus now has MIE bit set

    # Test 3: Read and set bits in mie (0x304)
    # mie has interrupt enable bits for specific interrupt sources
    li x5, 0x00000888          # Set bits 3, 7, 11 (MSIE, MTIE, MEIE)
    csrrs x6, 0x304, x5        # Read mie into x6, set interrupt enable bits
    # x6 contains original mie value
    # mie now has MSIE, MTIE, and MEIE bits set

    # Test 4: Read and set bits in mtvec (0x305)
    # mtvec is the machine trap vector base address
    li x7, 0x00001000          # Set lower bits of trap vector
    csrrs x8, 0x305, x7        # Read mtvec into x8, set bits
    # x8 contains original mtvec value
    # mtvec now has additional bits set

    # Test 5: Read and set bits in mepc (0x341)
    # mepc is the machine exception program counter
    li x9, 0x00000001          # Set bit 0
    csrrs x10, 0x341, x9       # Read mepc into x10, set bit 0
    # x10 contains original mepc value
    # mepc now has bit 0 set

    # Test 6: Read and set bits in mcause (0x342)
    # mcause stores the cause of the last exception
    li x11, 0x80000000         # Set interrupt bit (bit 31)
    csrrs x12, 0x342, x11      # Read mcause into x12, set interrupt bit
    # x12 contains original mcause value
    # mcause now has interrupt bit set

    # Test 7: Read and set bits in mvendorid (0xF11)
    # mvendorid is read-only vendor ID (0x9737978 from csr.v)
    li x13, 0xFFFFFFFF         # Try to set all bits (should have no effect on read-only CSR)
    csrrs x14, 0xF11, x13      # Read mvendorid into x14, attempt to set bits
    # x14 contains vendor ID value
    # mvendorid should remain unchanged (read-only)

    # Test 8: Read and set bits in marchid (0xF12)
    # marchid is read-only architecture ID (0x16f959d from csr.v)
    li x15, 0x0000FFFF         # Try to set lower 16 bits
    csrrs x16, 0xF12, x15      # Read marchid into x16, attempt to set bits
    # x16 contains architecture ID value
    # marchid should remain unchanged (read-only)

    # Test 9: Multiple CSRRS operations on same CSR
    # Test that bits accumulate when using CSRRS multiple times
    li x17, 0x00000001         # Set bit 0
    csrrs x18, 0xB00, x17      # First set bit 0 in mcycle
    li x19, 0x00000002         # Set bit 1
    csrrs x20, 0xB00, x19      # Then set bit 1 in mcycle
    # Now mcycle should have both bits 0 and 1 set

    # Test 10: CSRRS with x0 as destination (discard read value)
    li x21, 0x00000004         # Set bit 2
    csrrs x0, 0xB00, x21       # Set bit 2 in mcycle, discard read value
    # mcycle now has bit 2 set as well

    # Test 11: CSRRS with x0 as source (no bits set)
    csrrs x22, 0xB00, x0       # Read mcycle into x22, set no bits (x0 is always 0)
    # x22 contains current mcycle value
    # mcycle unchanged

    # Test 12: Test all bits pattern
    li x23, 0xFFFFFFFF         # Set all bits
    csrrs x24, 0x300, x23      # Read mstatus into x24, attempt to set all bits
    # x24 contains original mstatus
    # mstatus now has all writable bits set

    # End of test
    li gp, 1                   # Signal completion (following pattern from instrom.s)

    # Infinite loop to prevent running into undefined memory
end_loop:
    j end_loop

