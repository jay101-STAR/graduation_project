.section .text
.globl _start

_start:
    # Initialize base address for memory operations
    li sp, 0x80002000

    # ========== Test 1: EX-to-EX Forwarding (Back-to-back RAW hazard) ==========
    # Result should be available from EX/MEM pipeline register
    li x1, 10
    addi x2, x1, 5      # x2 = 15 (needs x1 from previous instruction)
    add x3, x2, x1      # x3 = 25 (needs x2 from previous instruction)

    # Verify: x3 should be 25
    li x4, 25
    bne x3, x4, test_fail

    # ========== Test 2: MEM-to-EX Forwarding (One NOP between) ==========
    # Result should be available from MEM/WB pipeline register
    li x5, 20
    nop                 # One cycle delay
    addi x6, x5, 10     # x6 = 30 (needs x5 from two instructions ago)

    # Verify: x6 should be 30
    li x7, 30
    bne x6, x7, test_fail

    # ========== Test 3: WB-to-EX Forwarding (Two NOPs between) ==========
    # Result should be available from WB stage
    li x8, 100
    nop
    nop
    addi x9, x8, 50     # x9 = 150 (needs x8 from three instructions ago)

    # Verify: x9 should be 150
    li x10, 150
    bne x9, x10, test_fail

    # ========== Test 4: Load-Use Hazard (Must stall) ==========
    # Store a value to memory
    li x11, 0x12345678
    sw x11, 0(sp)

    # Load-use hazard: load followed immediately by use
    lw x12, 0(sp)       # Load from memory
    addi x13, x12, 1    # Use x12 immediately (must stall 1 cycle)

    # Verify: x13 should be 0x12345679
    li x14, 0x12345679
    bne x13, x14, test_fail

    # ========== Test 5: Multiple Dependencies ==========
    # Test multiple registers with dependencies
    li x15, 5
    li x16, 3
    add x17, x15, x16   # x17 = 8
    sub x18, x17, x15   # x18 = 3 (depends on x17)
    mul x19, x18, x16   # x19 = 9 (depends on x18)

    # Verify: x19 should be 9
    li x20, 9
    bne x19, x20, test_fail

    # ========== Test 6: Branch with Data Hazard ==========
    # Test branch instruction with forwarding
    li x21, 42
    addi x22, x21, 8    # x22 = 50
    li x23, 50
    bne x22, x23, test_fail  # Branch depends on x22

    # ========== Test 7: Store with Data Hazard ==========
    # Test store instruction with forwarding
    li x24, 0xDEADBEEF
    add x25, x24, x0    # x25 = 0xDEADBEEF
    sw x25, 4(sp)       # Store x25 (depends on previous instruction)
    lw x26, 4(sp)       # Load back
    bne x26, x24, test_fail

    # ========== All Tests Passed ==========
test_pass:
    li gp, 1            # tohost = 1 (success)
    j end

test_fail:
    li gp, 2            # tohost = 2 (failure)
    j end

end:
    j end               # Infinite loop
