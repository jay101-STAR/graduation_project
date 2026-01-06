.text
.global _start
_start:
  lui  x3, 0x01000
  addi x1, x0, 4
  addi x2, x1, 10
  add  x4, x3, x2
  auipc x6, 0x00004
  auipc x7, 0x00004
  sll  x8, x7, x1
  slli x9, x7, 4
