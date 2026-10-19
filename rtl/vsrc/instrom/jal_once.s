.section .text
.globl _start
.option norvc
.option norelax
_start:
  li x3, 0
  la x5, target
  la x6, return_address
  nop
  jal x7, target
return_address:
  li x3, 2
  j hang
target:
  bne x7, x6, fail
  li x3, 1
  j hang
fail:
  li x3, 2
hang:
  j hang
