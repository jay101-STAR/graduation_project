.section .text
.globl _start
.option norvc

_start:
  li x3, 0
  li x5, -100
  li x6, 3
  # Adjacent DIV/REM with signed results and immediate dependencies.
  div x7, x5, x6
  rem x8, x5, x6
  div x10, x7, x6
  rem x11, x10, x6
  li x9, -33
  bne x7, x9, fail
  li x9, -1
  bne x8, x9, fail
  li x9, -11
  bne x10, x9, fail
  li x9, -2
  bne x11, x9, fail

  # Unsigned mode, consecutive same-destination writes, and x0.
  li x5, -1
  divu x7, x5, x6
  remu x8, x5, x6
  li x9, 0x55555555
  bne x7, x9, fail
  bne x8, x0, fail
  li x5, 100
  div x7, x5, x6
  div x7, x7, x6
  rem x7, x7, x6
  div x0, x5, x6
  li x9, 2
  bne x7, x9, fail

  # Short paths back to back must never reuse the preceding raw done.
  li x6, 1
  div x7, x5, x6
  rem x8, x5, x6
  divu x10, x5, x0
  remu x11, x5, x0
  bne x7, x5, fail
  bne x8, x0, fail
  li x9, -1
  bne x10, x9, fail
  bne x11, x5, fail
  li x5, 0x80000000
  li x6, -1
  div x7, x5, x6
  rem x8, x5, x6
  bne x7, x5, fail
  bne x8, x0, fail
  li x5, 7
  li x6, 8
  divu x7, x5, x6
  remu x8, x5, x6
  bne x7, x0, fail
  bne x8, x5, fail

  # MUL/DIV/REM transitions and dependency forwarding.
  li x5, -7
  li x6, 9
  mul x7, x5, x6
  div x8, x7, x6
  rem x10, x7, x6
  mul x11, x8, x6
  bne x8, x5, fail
  bne x10, x0, fail
  bne x11, x7, fail

  # Load-to-DIV and DIV-to-store dependencies.
  li x13, 0x80005000
  li x5, 100
  li x6, 3
  sw x5, 0(x13)
  lw x5, 0(x13)
  div x7, x5, x6
  sw x7, 4(x13)
  lw x8, 4(x13)
  li x9, 33
  bne x8, x9, fail
  li x3, 1
  j hang
fail:
  li x3, 2
hang:
  j hang
