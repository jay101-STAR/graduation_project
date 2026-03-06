#!/bin/bash

# Script to fully prepare RISC-V test memory images for simulation/FPGA init
# Usage: ./prepare_test.sh <test_elf_file>

if [ $# -lt 1 ]; then
  echo "Usage: $0 <test_elf_file>"
  echo "Example: $0 verification/riscv-tests/isa/rv32ui-p-lw"
  exit 1
fi

TEST_FILE=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
DATARAM_DIR="${SCRIPT_DIR}/vsrc/dataram"
MEM_TOOL="${DATARAM_DIR}/mem_image_tool.py"
INSTROM_HEX="${INSTROM_DIR}/instrom.hex"

# Check if test file exists
if [ ! -f "$TEST_FILE" ]; then
  echo "Error: Test file '$TEST_FILE' not found"
  exit 1
fi

echo "Preparing test: $TEST_FILE"
echo "================================"

echo "1. Converting ELF to instrom.hex..."
riscv32-unknown-elf-objcopy -O binary "$TEST_FILE" "${INSTROM_HEX}.bin"
od -An -tx4 -w4 -v "${INSTROM_HEX}.bin" | awk '{print $1}' > "${INSTROM_HEX}"
rm -f "${INSTROM_HEX}.bin"

echo "2. Initializing bank0.hex/bank1.hex from instrom.hex..."
python3 "${MEM_TOOL}" init-instrom --instrom "${INSTROM_HEX}" --out-dir "${DATARAM_DIR}"

echo "3. Overlaying .data section into bank hex files..."
python3 "${MEM_TOOL}" overlay-data --elf "$TEST_FILE" --out-dir "${DATARAM_DIR}"

echo "4. Emitting bank0/1.coe and bank0/1.mem..."
python3 "${MEM_TOOL}" emit --dir "${DATARAM_DIR}"

echo ""
echo "Test preparation complete!"
echo "You can now run:"
echo "  cd rtl"
echo "  make simv_build"
echo "  ./simv -l sim.log"
