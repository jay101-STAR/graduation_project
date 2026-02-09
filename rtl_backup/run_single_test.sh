#!/bin/bash

# Single Test Runner - 用于测试单个 RISC-V 测试

if [ $# -ne 1 ]; then
    echo "Usage: $0 <test_name>"
    echo "Example: $0 rv32ui-p-add"
    exit 1
fi

TEST_NAME=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RISCV_TESTS_DIR="${SCRIPT_DIR}/../verification/riscv-tests/isa"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"

# Find test file
TEST_FILE=$(find "${RISCV_TESTS_DIR}" -name "${TEST_NAME}" -type f ! -name "*.dump" | head -1)

if [ -z "${TEST_FILE}" ]; then
    echo "Error: Test '${TEST_NAME}' not found"
    exit 1
fi

echo "========================================="
echo "Running single test: ${TEST_NAME}"
echo "========================================="
echo ""

# Backup original hex
BACKUP_HEX="${INSTROM_DIR}/instrom.hex.backup"
if [ -f "${INSTROM_DIR}/instrom.hex" ]; then
    cp "${INSTROM_DIR}/instrom.hex" "${BACKUP_HEX}"
fi

# Convert ELF to HEX
echo "Converting ELF to HEX..."
TEMP_HEX="${INSTROM_DIR}/test_temp.hex"
riscv32-unknown-elf-objcopy -O binary "${TEST_FILE}" "${TEMP_HEX}.bin"
od -An -tx4 -w4 -v "${TEMP_HEX}.bin" | awk '{print $1}' > "${TEMP_HEX}"
rm -f "${TEMP_HEX}.bin"

# Copy to instrom.hex
cp "${TEMP_HEX}" "${INSTROM_DIR}/instrom.hex"

echo "Running simulation..."
cd "${SCRIPT_DIR}"

# Run simulation
./simv

# Restore original hex
if [ -f "${BACKUP_HEX}" ]; then
    mv "${BACKUP_HEX}" "${INSTROM_DIR}/instrom.hex"
fi

# Clean up
rm -f "${TEMP_HEX}"

echo ""
echo "========================================="
echo "Test completed"
echo "========================================="
echo ""
echo "To view waveform, run: make verdi"
