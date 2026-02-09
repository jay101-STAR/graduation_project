#!/bin/bash

# Script to prepare RISC-V test for simulation
# Usage: ./prepare_test.sh <test_elf_file>

if [ $# -lt 1 ]; then
  echo "Usage: $0 <test_elf_file>"
  echo "Example: $0 verification/riscv-tests/isa/rv32ui-p-lw"
  exit 1
fi

TEST_FILE=$1
DATAROM_DIR="/home/jay/Desktop/graduation_project/rtl/vsrc/dataram"

# Check if test file exists
if [ ! -f "$TEST_FILE" ]; then
  echo "Error: Test file '$TEST_FILE' not found"
  exit 1
fi

echo "Preparing test: $TEST_FILE"
echo "================================"

echo "2. Extracting data memory (bank0/bank1)..."
"${DATAROM_DIR}/extract_data.sh" "$TEST_FILE" "${DATAROM_DIR}/dataram.hex"

echo ""
echo "Test preparation complete!"
echo "You can now run: cd rtl && make comp"
