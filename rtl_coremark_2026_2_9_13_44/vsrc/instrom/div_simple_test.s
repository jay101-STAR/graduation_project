.section .text
.globl _start

_start:
    # Simple test: 20 / 4 = 5
    li x1, 20
    li x2, 4
    div x3, x1, x2      # x3 should be 5

    # Check result
    li x4, 5
    bne x3, x4, fail

    # Test passed
    li x5, 1
    lui x6, 0x80001
    sw x5, 0(x6)        # Write 1 to tohost
    j done

fail:
    # Test failed
    li x5, 3
    lui x6, 0x80001
    sw x5, 0(x6)        # Write 3 to tohost

done:
    j done
