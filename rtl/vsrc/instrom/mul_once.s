.section .text
.globl _start
.option norvc

_start:
  # Keep x3 (the register tohost) zero until the result is checked.
  addi x3, x0, 0
  addi x5, x0, 7
  addi x6, x0, 9
  # Separate operand setup from MUL to make its waveform easy to inspect.
  nop
  nop
  nop

mul_once:
  mul x7, x5, x6           # The only multiplication: 7 * 9 = 63.
after_mul:
  addi x8, x7, 0          # Immediate consumer checks result forwarding too.
  addi x9, x0, 63
  bne x8, x9, fail
  addi x3, x0, 1          # PASS.
  j hang

fail:
  addi x3, x0, 2          # FAIL.
hang:
  j hang
