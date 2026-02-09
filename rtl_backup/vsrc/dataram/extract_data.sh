#!/bin/bash

# Script to extract .data section from RISC-V ELF file and convert to hex format
# Usage: ./extract_data.sh <elf_file> [output_hex]

if [ $# -lt 1 ]; then
    echo "Usage: $0 <elf_file> [output_hex]"
    exit 1
fi

ELF_FILE=$1
OUTPUT_HEX=${2:-"dataram.hex"}

# Check if ELF file exists
if [ ! -f "$ELF_FILE" ]; then
    echo "Error: ELF file '$ELF_FILE' not found"
    exit 1
fi

# Extract .data section to binary file
DATA_BIN="${OUTPUT_HEX%.hex}.bin"
riscv32-unknown-elf-objcopy -O binary -j .data "$ELF_FILE" "$DATA_BIN" 2>/dev/null

# Check if .data section exists
if [ ! -f "$DATA_BIN" ] || [ ! -s "$DATA_BIN" ]; then
    echo "Warning: No .data section found in $ELF_FILE, creating empty hex file"
    echo "" > "$OUTPUT_HEX"
    rm -f "$DATA_BIN"
    exit 0
fi

# Convert binary to hex format (32-bit words, little-endian)
hexdump -v -e '1/4 "%08x\n"' "$DATA_BIN" > "$OUTPUT_HEX"

echo "Data section extracted to $OUTPUT_HEX"
echo "Size: $(wc -l < "$OUTPUT_HEX") words ($(stat -c%s "$DATA_BIN") bytes)"

# Clean up binary file
rm -f "$DATA_BIN"
