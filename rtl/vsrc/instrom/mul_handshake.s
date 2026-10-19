.section .text
.globl _start
.option norvc

_start:
  li x3, 0
  li x5, -7
  li x6, 9
  # Consecutive dependent operations; newest result must be forwarded.
  mul x7, x5, x6
  mul x8, x7, x6
  li x9, -567
  bne x8, x9, fail
  # Consecutive writes to the same destination and x0 must not reuse done.
  mul x7, x5, x6
  mul x7, x7, x6
  mul x0, x5, x6
  bne x7, x9, fail
  # Back-to-back high-half variants with mixed signedness.
  li x5, -1
  li x6, -1
  mulh x7, x5, x6
  mulhsu x8, x5, x6
  mulhu x10, x5, x6
  bne x7, x0, fail
  li x9, -1
  bne x8, x9, fail
  li x9, -2
  bne x10, x9, fail
  # Alternate MUL/DIV/REM and immediately use each result.
  li x5, 100
  li x6, 3
  div x7, x5, x6
  mul x8, x7, x6
  rem x10, x8, x6
  mul x11, x8, x6
  div x12, x11, x6
  li x9, 99
  bne x8, x9, fail
  bne x10, x0, fail
  bne x12, x9, fail
  # Load-to-MUL and MUL-to-store result dependencies.
  li x13, 0x80005000
  li x5, 7
  sw x5, 0(x13)
  lw x5, 0(x13)
  mul x7, x5, x6
  sw x7, 4(x13)
  lw x8, 4(x13)
  li x9, 21
  bne x8, x9, fail
  li x3, 1
  j hang
fail:
  li x3, 2
hang:
  j hang
