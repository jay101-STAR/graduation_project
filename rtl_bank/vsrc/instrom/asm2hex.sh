#!/bin/bash
# 用法: ./asm2hex.sh filename.s
# 比如: ./asm2hex.sh test.s 会生成 test.hex

set -e

# 检查参数
if [ -z "$1" ]; then
  echo "❌ 错误：请输入 .s 汇编文件名作为参数，例如：./asm2hex.sh test.s"
  exit 1
fi

# 提取文件名（不带扩展名）
input_file="$1"
base_name="${input_file%.*}"

# 编译生成中间文件
riscv32-unknown-elf-as -march=rv32im -mno-relax -o "${base_name}.o" "$input_file"

# 转换为纯二进制文件
riscv32-unknown-elf-objcopy -O binary "${base_name}.o" "${base_name}.bin"

# 输出十六进制，每行一个指令，写入 .hex 文件
hexdump -ve '1/4 "%08x\n"' "${base_name}.bin" >"${base_name}.hex"

echo "✅ 成功生成：${base_name}.hex"
