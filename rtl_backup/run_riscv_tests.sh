#!/bin/bash

# RISC-V Tests Batch Runner
# This script runs riscv-tests suite and reports results

# set -e disabled to avoid issues with arithmetic operations
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RISCV_TESTS_DIR="${SCRIPT_DIR}/../verification/riscv-tests/isa"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
RESULTS_DIR="${SCRIPT_DIR}/test_results"

# Create results directory
mkdir -p "${RESULTS_DIR}"

# Test categories to run
# rv32ui: User-level integer tests
# rv32um: User-level multiply/divide tests (if M extension implemented)
TEST_CATEGORIES="rv32ui"

# Statistics
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Result files
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SUMMARY_FILE="${RESULTS_DIR}/summary_${TIMESTAMP}.txt"
DETAILED_LOG="${RESULTS_DIR}/detailed_${TIMESTAMP}.log"

echo "========================================" | tee "${SUMMARY_FILE}"
echo "RISC-V Tests Batch Runner" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Start time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"

# Function to convert ELF to HEX
elf_to_hex() {
    local elf_file=$1
    local hex_file=$2

    # Use objcopy to convert ELF to binary, then to hex
    riscv32-unknown-elf-objcopy -O binary "${elf_file}" "${hex_file}.bin"
    od -An -tx4 -w4 -v "${hex_file}.bin" | awk '{print $1}' > "${hex_file}"
    rm -f "${hex_file}.bin"
}

# Function to run a single test
run_single_test() {
    local test_file=$1
    local test_name=$(basename "${test_file}")

    echo -ne "${BLUE}Testing: ${test_name}${NC} ... "

    # Convert ELF to HEX
    local hex_file="${INSTROM_DIR}/test_temp.hex"
    if ! elf_to_hex "${test_file}" "${hex_file}" 2>>"${DETAILED_LOG}"; then
        echo -e "${YELLOW}SKIP${NC} (conversion failed)"
        echo "[SKIP] ${test_name}: ELF to HEX conversion failed" >> "${SUMMARY_FILE}"
        ((SKIPPED_TESTS++))
        return
    fi

    # Backup original instrom.hex
    if [ -f "${INSTROM_DIR}/instrom.hex" ]; then
        cp "${INSTROM_DIR}/instrom.hex" "${INSTROM_DIR}/instrom.hex.backup"
    fi

    # Copy test hex to instrom.hex
    cp "${hex_file}" "${INSTROM_DIR}/instrom.hex"

    # Recompile (only recompile instrom.v, not full VCS compile)
    # We'll use the existing simv binary
    cd "${SCRIPT_DIR}"

    # Run simulation
    local sim_log="${RESULTS_DIR}/${test_name}.log"
    if timeout 10s ./simv > "${sim_log}" 2>&1; then
        # Check result
        if grep -q "TEST PASSED" "${sim_log}"; then
            echo -e "${GREEN}PASS${NC}"
            echo "[PASS] ${test_name}" >> "${SUMMARY_FILE}"
            ((PASSED_TESTS++))
        elif grep -q "TEST FAILED" "${sim_log}"; then
            local tohost=$(grep "TEST FAILED" "${sim_log}" | sed -n 's/.*tohost = *\([0-9]*\).*/\1/p')
            echo -e "${RED}FAIL${NC} (tohost=${tohost})"
            echo "[FAIL] ${test_name}: tohost=${tohost}" >> "${SUMMARY_FILE}"
            ((FAILED_TESTS++))
        else
            echo -e "${YELLOW}UNKNOWN${NC}"
            echo "[UNKNOWN] ${test_name}: No clear result" >> "${SUMMARY_FILE}"
            ((FAILED_TESTS++))
        fi
    else
        echo -e "${RED}TIMEOUT${NC}"
        echo "[TIMEOUT] ${test_name}: Simulation timeout" >> "${SUMMARY_FILE}"
        ((FAILED_TESTS++))
    fi

    # Restore original instrom.hex
    if [ -f "${INSTROM_DIR}/instrom.hex.backup" ]; then
        mv "${INSTROM_DIR}/instrom.hex.backup" "${INSTROM_DIR}/instrom.hex"
    fi

    # Clean up
    rm -f "${hex_file}"

    ((TOTAL_TESTS++))
}

# Main test loop
echo "Searching for tests in: ${RISCV_TESTS_DIR}" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"

for category in ${TEST_CATEGORIES}; do
    echo "========================================" | tee -a "${SUMMARY_FILE}"
    echo "Category: ${category}" | tee -a "${SUMMARY_FILE}"
    echo "========================================" | tee -a "${SUMMARY_FILE}"

    # Find all test files for this category
    test_files=$(find "${RISCV_TESTS_DIR}" -name "${category}-p-*" -type f ! -name "*.dump" | sort)

    if [ -z "${test_files}" ]; then
        echo "No tests found for category: ${category}" | tee -a "${SUMMARY_FILE}"
        continue
    fi

    # Run each test
    for test_file in ${test_files}; do
        run_single_test "${test_file}"
    done

    echo "" | tee -a "${SUMMARY_FILE}"
done

# Print summary
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Test Summary" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Total tests:   ${TOTAL_TESTS}" | tee -a "${SUMMARY_FILE}"
echo -e "${GREEN}Passed tests:  ${PASSED_TESTS}${NC}" | tee -a "${SUMMARY_FILE}"
echo -e "${RED}Failed tests:  ${FAILED_TESTS}${NC}" | tee -a "${SUMMARY_FILE}"
echo -e "${YELLOW}Skipped tests: ${SKIPPED_TESTS}${NC}" | tee -a "${SUMMARY_FILE}"

if [ ${TOTAL_TESTS} -gt 0 ]; then
    PASS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "Pass rate:     ${PASS_RATE}%" | tee -a "${SUMMARY_FILE}"
fi

echo "" | tee -a "${SUMMARY_FILE}"
echo "End time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "Results saved to: ${SUMMARY_FILE}" | tee -a "${SUMMARY_FILE}"
echo "Detailed logs in: ${RESULTS_DIR}" | tee -a "${SUMMARY_FILE}"

# Exit with error if any tests failed
if [ ${FAILED_TESTS} -gt 0 ]; then
    exit 1
else
    exit 0
fi
