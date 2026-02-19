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
DATA_ADDR_FILE="${OUTPUT_DIR}/data_addr.txt"

mkdir -p "$OUTPUT_DIR"

# Check if ELF file exists
if [ ! -f "$ELF_FILE" ]; then
  echo "Error: ELF file '$ELF_FILE' not found"
  exit 1
fi

# Get .data section address from ELF file
DATA_ADDR=$(riscv32-unknown-elf-readelf -S "$ELF_FILE" | awk '/\.data / && /PROGBITS/ {print $5}')
if [ -z "$DATA_ADDR" ]; then
  echo "Warning: No .data section found in $ELF_FILE, creating empty bank hex files"
  : >"$BANK0_HEX"
  : >"$BANK1_HEX"
  if [ -n "$COMBINED_HEX" ]; then
    : >"$COMBINED_HEX"
  fi
  exit 0
fi

# Convert hex address to decimal and calculate word offset
DATA_ADDR_DEC=$((0x$DATA_ADDR))
BASE_ADDR=$((0x80000000))
BYTE_OFFSET=$((DATA_ADDR_DEC - BASE_ADDR))
WORD_OFFSET=$((BYTE_OFFSET / 4))

echo "Data section address: 0x$DATA_ADDR (word offset: $WORD_OFFSET)"
echo "$WORD_OFFSET" > "$DATA_ADDR_FILE"

# Extract .data section to binary file
DATA_BIN="$(mktemp)"
riscv32-unknown-elf-objcopy -O binary -j .data "$ELF_FILE" "$DATA_BIN" 2>/dev/null

# Check if .data section exists
if [ ! -f "$DATA_BIN" ] || [ ! -s "$DATA_BIN" ]; then
  echo "Warning: .data section is empty, creating empty bank hex files"
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

# Split into bank0/bank1 with address prefixes for $readmemh
# Bank0 holds even word addresses, Bank1 holds odd word addresses
# Each bank stores at index = word_addr / 2
: >"$BANK0_HEX"
: >"$BANK1_HEX"

LINE_NUM=0
BANK0_ADDR=-1
BANK1_ADDR=-1

while IFS= read -r hex_word; do
  CURRENT_WORD_ADDR=$((WORD_OFFSET + LINE_NUM))
  BANK_INDEX=$((CURRENT_WORD_ADDR / 2))

  if [ $((CURRENT_WORD_ADDR % 2)) -eq 0 ]; then
    # Even word address -> Bank0
    if [ $BANK0_ADDR -ne $BANK_INDEX ]; then
      # Need to set address
      printf "@%x\n" $BANK_INDEX >> "$BANK0_HEX"
      BANK0_ADDR=$BANK_INDEX
    fi
    echo "$hex_word" >> "$BANK0_HEX"
    BANK0_ADDR=$((BANK0_ADDR + 1))
  else
    # Odd word address -> Bank1
    if [ $BANK1_ADDR -ne $BANK_INDEX ]; then
      # Need to set address
      printf "@%x\n" $BANK_INDEX >> "$BANK1_HEX"
      BANK1_ADDR=$BANK_INDEX
    fi
    echo "$hex_word" >> "$BANK1_HEX"
    BANK1_ADDR=$((BANK1_ADDR + 1))
  fi

  LINE_NUM=$((LINE_NUM + 1))
done < "$TMP_HEX"

TOTAL_WORDS=$(wc -l <"$TMP_HEX")
BANK0_WORDS=$(grep -v "^@" "$BANK0_HEX" | wc -l)
BANK1_WORDS=$(grep -v "^@" "$BANK1_HEX" | wc -l)
echo "Data section extracted to:"
echo "  Bank0: $BANK0_HEX (${BANK0_WORDS} words)"
echo "  Bank1: $BANK1_HEX (${BANK1_WORDS} words)"
if [ -n "$COMBINED_HEX" ]; then
  echo "  Combined: $COMBINED_HEX (${TOTAL_WORDS} words)"
fi
echo "Total size: ${TOTAL_WORDS} words ($(stat -c%s "$DATA_BIN") bytes)"
echo "Loaded at word address: $WORD_OFFSET (physical: 0x$(printf '%08x' $DATA_ADDR_DEC))"

# Clean up binary file
rm -f "$DATA_BIN" "$TMP_HEX"
