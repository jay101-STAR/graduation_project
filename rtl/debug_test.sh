#!/bin/bash

# Debug version of test runner

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RISCV_TESTS_DIR="${SCRIPT_DIR}/../verification/riscv-tests/isa"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
DATARAM_DIR="${SCRIPT_DIR}/vsrc/dataram"
RESULTS_DIR="${SCRIPT_DIR}/test_results"

mkdir -p "${RESULTS_DIR}"

TEST_PATTERN="${1:-rv32ui-p-add}"

echo "=== Debug Test Runner ==="
echo "Pattern: ${TEST_PATTERN}"
echo ""

# Find tests
test_files=$(find "${RISCV_TESTS_DIR}" -name "${TEST_PATTERN}" -type f ! -name "*.dump" | sort)

if [ -z "${test_files}" ]; then
    echo "No tests found"
    exit 1
fi

echo "Found tests:"
echo "${test_files}"
echo ""

TOTAL=0
PASSED=0

# Backup
BACKUP_HEX="${INSTROM_DIR}/instrom.hex.debug_backup"
BACKUP_BANK0="${DATARAM_DIR}/bank0.hex.debug_backup"
BACKUP_BANK1="${DATARAM_DIR}/bank1.hex.debug_backup"
BACKUP_INST_BANK0="${DATARAM_DIR}/inst_bank0.hex.debug_backup"
BACKUP_INST_BANK1="${DATARAM_DIR}/inst_bank1.hex.debug_backup"
if [ -f "${INSTROM_DIR}/instrom.hex" ]; then
    cp "${INSTROM_DIR}/instrom.hex" "${BACKUP_HEX}"
fi
if [ -f "${DATARAM_DIR}/bank0.hex" ]; then
    cp "${DATARAM_DIR}/bank0.hex" "${BACKUP_BANK0}"
fi
if [ -f "${DATARAM_DIR}/bank1.hex" ]; then
    cp "${DATARAM_DIR}/bank1.hex" "${BACKUP_BANK1}"
fi
if [ -f "${DATARAM_DIR}/inst_bank0.hex" ]; then
    cp "${DATARAM_DIR}/inst_bank0.hex" "${BACKUP_INST_BANK0}"
fi
if [ -f "${DATARAM_DIR}/inst_bank1.hex" ]; then
    cp "${DATARAM_DIR}/inst_bank1.hex" "${BACKUP_INST_BANK1}"
fi

for test_file in ${test_files}; do
    test_name=$(basename "${test_file}")
    echo "Running: ${test_name}"

    # Convert
    temp_hex="${INSTROM_DIR}/test_temp.hex"
    riscv32-unknown-elf-objcopy -O binary "${test_file}" "${temp_hex}.bin" 2>/dev/null
    od -An -tx4 -w4 -v "${temp_hex}.bin" | awk '{print $1}' > "${temp_hex}"
    rm -f "${temp_hex}.bin"

    # Run
    cp "${temp_hex}" "${INSTROM_DIR}/instrom.hex"
    "${DATARAM_DIR}/split_instrom_to_banks.sh" "${INSTROM_DIR}/instrom.hex" "${DATARAM_DIR}" >/dev/null
    "${DATARAM_DIR}/extract_data.sh" "${test_file}" "${DATARAM_DIR}" >/dev/null
    log="${RESULTS_DIR}/${test_name}_debug.log"

    if timeout 10s ./simv > "${log}" 2>&1; then
        if grep -q "TEST PASSED" "${log}"; then
            echo "  Result: PASS"
            ((PASSED++))
        else
            echo "  Result: FAIL"
        fi
    else
        echo "  Result: TIMEOUT"
    fi

    rm -f "${temp_hex}"
    ((TOTAL++))
done

# Restore
if [ -f "${BACKUP_HEX}" ]; then
    mv "${BACKUP_HEX}" "${INSTROM_DIR}/instrom.hex"
fi
if [ -f "${BACKUP_BANK0}" ]; then
    mv "${BACKUP_BANK0}" "${DATARAM_DIR}/bank0.hex"
fi
if [ -f "${BACKUP_BANK1}" ]; then
    mv "${BACKUP_BANK1}" "${DATARAM_DIR}/bank1.hex"
fi
if [ -f "${BACKUP_INST_BANK0}" ]; then
    mv "${BACKUP_INST_BANK0}" "${DATARAM_DIR}/inst_bank0.hex"
fi
if [ -f "${BACKUP_INST_BANK1}" ]; then
    mv "${BACKUP_INST_BANK1}" "${DATARAM_DIR}/inst_bank1.hex"
fi

echo ""
echo "=== Summary ==="
echo "Total: ${TOTAL}"
echo "Passed: ${PASSED}"
echo "Done!"
