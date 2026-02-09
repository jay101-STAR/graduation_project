#!/bin/bash
# Convert RISC-V ELF test to hex format for $readmemh

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input.elf> <output.hex>"
    exit 1
fi

INPUT_ELF=$1
OUTPUT_HEX=$2

# Try different toolchain prefixes
if command -v riscv64-unknown-elf-objcopy &> /dev/null; then
    OBJCOPY=riscv64-unknown-elf-objcopy
elif command -v riscv32-unknown-elf-objcopy &> /dev/null; then
    OBJCOPY=riscv32-unknown-elf-objcopy
else
    echo "Error: No RISC-V objcopy found"
    exit 1
fi

# Extract binary starting from 0x80000000
$OBJCOPY -O binary $INPUT_ELF /tmp/test.bin

# Convert binary to hex format (32-bit words, little-endian)
hexdump -v -e '1/4 "%08x\n"' /tmp/test.bin > $OUTPUT_HEX

echo "Converted $INPUT_ELF to $OUTPUT_HEX"
echo "Size: $(wc -l < $OUTPUT_HEX) instructions"
