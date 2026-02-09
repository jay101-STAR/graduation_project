# Simplified startup code for RV32IM CPU (no RVC, no FPU)
# Compatible with graduation project CPU

#define REGBYTES 4

  .section ".text.init"
  .globl _start
_start:
  # Initialize all registers to 0
  li  x1, 0
  li  x2, 0
  li  x3, 0
  li  x4, 0
  li  x5, 0
  li  x6, 0
  li  x7, 0
  li  x8, 0
  li  x9, 0
  li  x10,0
  li  x11,0
  li  x12,0
  li  x13,0
  li  x14,0
  li  x15,0
  li  x16,0
  li  x17,0
  li  x18,0
  li  x19,0
  li  x20,0
  li  x21,0
  li  x22,0
  li  x23,0
  li  x24,0
  li  x25,0
  li  x26,0
  li  x27,0
  li  x28,0
  li  x29,0
  li  x30,0
  li  x31,0

  # Initialize global pointer
.option push
.option norelax
  la gp, __global_pointer$
.option pop

  # Initialize stack pointer
  # Stack grows downward from 0x80008000 (32KB mark, leaving 32KB for stack)
  # CPU has 64KB total memory (0x80000000-0x8000FFFF)
  # Code+data uses ~17KB, so 32KB stack should be sufficient
  li sp, 0x80008000

  # Debug: print 'S' to UART (0x10000000) to confirm startup
  # DISABLED: CPU doesn't have UART peripheral
  # li t0, 0x10000000
  # li t1, 83
  # sw t1, 0(t0)

  # Initialize thread pointer
  la  tp, _end
  addi tp, tp, 63
  andi tp, tp, -64

  # Jump to _init (which calls main)
  j _init

  # Simple trap handler - just hang
  .align 2
  .globl trap_entry
trap_entry:
  j trap_entry

# tohost is at fixed address 0x80001000 - no need to define here
# The CPU monitors this address for test completion
