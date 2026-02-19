#!/bin/bash
# 用法：./asm2hex_llvm.sh filename.s
# 例如：./asm2hex_llvm.sh test.s

set -e

if [ -z "$1" ]; then
  echo "❌ 错误：请输入 .s 文件名"
  exit 1
fi

input_file="$1"
base_name="${input_file%.*}"

# 汇编（LLVM MC）
llvm-mc \
  -triple=riscv32 \
  -mattr=+m \
  -filetype=obj \
  "$input_file" \
  -o "${base_name}.o"

# ELF -> binary
llvm-objcopy \
  -O binary \
  "${base_name}.o" \
  "${base_name}.bin"

# binary -> hex（32-bit，小端）
hexdump -ve '1/4 "%08x\n"' \
  "${base_name}.bin" \
  >"${base_name}.hex"

echo "✅ 成功生成：${base_name}.hex"

# object -> dump（反汇编）
if command -v llvm-objdump >/dev/null 2>&1; then
  riscv32-unknown-elf-objdump -d "${base_name}.o" >"${base_name}.dump"
  echo "✅ 成功生成：${base_name}.dump"
else
  echo "⚠️ 未找到 llvm-objdump，已跳过 dump 生成"
fi
