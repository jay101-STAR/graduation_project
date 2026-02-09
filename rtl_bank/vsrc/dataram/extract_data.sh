#!/bin/bash

# Script to extract .data section from RISC-V ELF file and convert to banked hex format
# Usage: ./extract_data.sh <elf_file> [output_dir_or_hex]

if [ $# -lt 1 ]; then
  echo "Usage: $0 <elf_file> [output_dir_or_hex]"
  exit 1
fi

ELF_FILE=$1
OUTPUT_PATH=${2:-""}

# Resolve output paths
if [ -z "$OUTPUT_PATH" ]; then
  OUTPUT_DIR="."
  COMBINED_HEX=""
elif [[ "$OUTPUT_PATH" == *.hex ]]; then
  OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"
  COMBINED_HEX="$OUTPUT_PATH"
else
  OUTPUT_DIR="$OUTPUT_PATH"
  COMBINED_HEX=""
fi

BANK0_HEX="${OUTPUT_DIR}/bank0.hex"
BANK1_HEX="${OUTPUT_DIR}/bank1.hex"

mkdir -p "$OUTPUT_DIR"

# Check if ELF file exists
if [ ! -f "$ELF_FILE" ]; then
  echo "Error: ELF file '$ELF_FILE' not found"
  exit 1
fi

# Extract .data section to binary file
DATA_BIN="$(mktemp)"
riscv32-unknown-elf-objcopy -O binary -j .data "$ELF_FILE" "$DATA_BIN" 2>/dev/null

# Check if .data section exists
if [ ! -f "$DATA_BIN" ] || [ ! -s "$DATA_BIN" ]; then
  echo "Warning: No .data section found in $ELF_FILE, creating empty bank hex files"
  : >"$BANK0_HEX"
  : >"$BANK1_HEX"
  if [ -n "$COMBINED_HEX" ]; then
    : >"$COMBINED_HEX"
  fi
  rm -f "$DATA_BIN"
  exit 0
fi

# Convert binary to hex format (32-bit words, little-endian)
TMP_HEX="$(mktemp)"
hexdump -v -e '1/4 "%08x\n"' "$DATA_BIN" >"$TMP_HEX"

# Optional combined hex (for compatibility/debug)
if [ -n "$COMBINED_HEX" ]; then
  cp "$TMP_HEX" "$COMBINED_HEX"
fi

# Split into bank0/bank1 (even/odd words)
: >"$BANK0_HEX"
: >"$BANK1_HEX"
awk -v b0="$BANK0_HEX" -v b1="$BANK1_HEX" 'NR%2==1{print >> b0} NR%2==0{print >> b1}' "$TMP_HEX"

TOTAL_WORDS=$(wc -l <"$TMP_HEX")
BANK0_WORDS=$(wc -l <"$BANK0_HEX")
BANK1_WORDS=$(wc -l <"$BANK1_HEX")
echo "Data section extracted to:"
echo "  Bank0: $BANK0_HEX (${BANK0_WORDS} words)"
echo "  Bank1: $BANK1_HEX (${BANK1_WORDS} words)"
if [ -n "$COMBINED_HEX" ]; then
  echo "  Combined: $COMBINED_HEX (${TOTAL_WORDS} words)"
fi
echo "Total size: ${TOTAL_WORDS} words ($(stat -c%s "$DATA_BIN") bytes)"

# Clean up binary file
rm -f "$DATA_BIN" "$TMP_HEX"
