#!/bin/bash

# Quick RISC-V Test Runner
# This version is optimized for faster testing by modifying instrom.v directly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RISCV_TESTS_DIR="${SCRIPT_DIR}/../verification/riscv-tests/isa"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
RESULTS_DIR="${SCRIPT_DIR}/test_results"

# Test selection
if [ $# -eq 0 ]; then
    # Default: run basic RV32UI tests
    TEST_PATTERN="rv32ui-p-*"
    echo "Usage: $0 [test_pattern]"
    echo "Running default tests: ${TEST_PATTERN}"
    echo ""
else
    TEST_PATTERN="$1"
fi

# Create results directory
mkdir -p "${RESULTS_DIR}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SUMMARY_FILE="${RESULTS_DIR}/summary_${TIMESTAMP}.txt"

# Statistics
TOTAL=0
PASSED=0
FAILED=0

echo "========================================"
echo "RISC-V Quick Test Runner"
echo "========================================"
echo "Pattern: ${TEST_PATTERN}"
echo "Start: $(date)"
echo ""

# Convert ELF to HEX
elf_to_hex() {
    local elf=$1
    local hex=$2
    riscv32-unknown-elf-objcopy -O binary "${elf}" "${hex}.bin" 2>/dev/null
    od -An -tx4 -w4 -v "${hex}.bin" | awk '{print $1}' > "${hex}"
    rm -f "${hex}.bin"
}

# Run single test
run_test() {
    local test_file=$1
    local test_name=$(basename "${test_file}")

    echo -ne "${BLUE}[${TOTAL}]${NC} ${test_name} ... "

    # Convert to hex
    local hex_file="${INSTROM_DIR}/${test_name}.hex"
    if ! elf_to_hex "${test_file}" "${hex_file}"; then
        echo -e "${YELLOW}SKIP${NC}"
        return
    fi

    # Update instrom.v to use this hex file
    local instrom_v="${INSTROM_DIR}/../instrom.v"
    sed -i.bak "s|\$readmemh(\".*\.hex\", inst_mem);|\$readmemh(\"${hex_file}\", inst_mem);|" "${instrom_v}"

    # Recompile instrom.v only
    cd "${SCRIPT_DIR}"
    if ! vcs -full64 -R +v2k -sverilog -debug_acc+dmptf -debug_region+cell+encrypt \
         -kdb -lca -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed \
         +define+FSDB_FILE=\"testbench.fsdb\" \
         -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab \
         ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a \
         -load ${VERDI_HOME}/share/PLI/VCS/LINUX64/libnovas.so:FSDBDumpCmd \
         ./vsrc/testbench.v ./vsrc/top.v ./vsrc/openmips.v ./vsrc/pc.v \
         ./vsrc/id.v ./vsrc/ex.v ./vsrc/registerfile.v ./vsrc/instrom.v \
         ./vsrc/csr.v ./vsrc/dataram.v \
         -o simv > /dev/null 2>&1; then
        echo -e "${RED}COMPILE_FAIL${NC}"
        mv "${instrom_v}.bak" "${instrom_v}"
        return
    fi

    # Run simulation
    local log="${RESULTS_DIR}/${test_name}.log"
    if timeout 5s ./simv > "${log}" 2>&1; then
        if grep -q "TEST PASSED" "${log}"; then
            echo -e "${GREEN}PASS${NC}"
            ((PASSED++))
        else
            local tohost=$(grep "TEST FAILED" "${log}" | sed -n 's/.*tohost = *\([0-9]*\).*/\1/p')
            echo -e "${RED}FAIL${NC} (tohost=${tohost})"
            ((FAILED++))
        fi
    else
        echo -e "${RED}TIMEOUT${NC}"
        ((FAILED++))
    fi

    # Restore instrom.v
    mv "${instrom_v}.bak" "${instrom_v}"
    rm -f "${hex_file}"

    ((TOTAL++))
}

# Find and run tests
test_files=$(find "${RISCV_TESTS_DIR}" -name "${TEST_PATTERN}" -type f ! -name "*.dump" | sort)

if [ -z "${test_files}" ]; then
    echo "No tests found matching: ${TEST_PATTERN}"
    exit 1
fi

for test in ${test_files}; do
    run_test "${test}"
done

# Summary
echo ""
echo "========================================"
echo "Summary"
echo "========================================"
echo "Total:  ${TOTAL}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ ${TOTAL} -gt 0 ]; then
    RATE=$((PASSED * 100 / TOTAL))
    echo "Rate:   ${RATE}%"
fi

echo ""
echo "End: $(date)"

[ ${FAILED} -eq 0 ]
