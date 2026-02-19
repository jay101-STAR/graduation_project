#!/bin/bash

# RISC-V Test Runner - Fast Version
# Uses hex file replacement without recompilation

# set -e disabled to avoid issues with arithmetic operations
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RISCV_TESTS_DIR="${SCRIPT_DIR}/../verification/riscv-tests/isa"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
DATARAM_DIR="${SCRIPT_DIR}/vsrc/dataram"
RESULTS_DIR="${SCRIPT_DIR}/test_results"

# Create results directory
mkdir -p "${RESULTS_DIR}"

# Test pattern (can be overridden by command line)
# Default: run both rv32ui and rv32um tests
if [ $# -eq 0 ]; then
  TEST_PATTERN="rv32u[i,m]-p-*"
else
  TEST_PATTERN="$1"
fi

# Optional skip regex on test basename (e.g. '^rv32ui-p-fence_i$')
SKIP_TEST_REGEX="${SKIP_TEST_REGEX:-}"

# Statistics
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0
PERF_SAMPLES=0
PERF_TOTAL_MCYCLE=0
PERF_TOTAL_MINSTRET=0
PERF_CPI_SUM=0

# Result file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SUMMARY_FILE="${RESULTS_DIR}/summary_${TIMESTAMP}.txt"
FAILED_TESTS_FILE="${RESULTS_DIR}/failed_tests_${TIMESTAMP}.txt"

# Print header
echo "========================================" | tee "${SUMMARY_FILE}"
echo "RISC-V Test Runner (Fast Mode)" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Test pattern: ${TEST_PATTERN}" | tee -a "${SUMMARY_FILE}"
echo "Start time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"

# Check if simv exists
if [ ! -f "${SCRIPT_DIR}/simv" ]; then
  echo -e "${RED}Error: simv not found. Please run 'make comp' first.${NC}"
  exit 1
fi

# Backup original instrom.hex and bank hex files
ORIGINAL_INST_HEX="${INSTROM_DIR}/instrom.hex"
BACKUP_INST_HEX="${INSTROM_DIR}/instrom.hex.original_backup"
ORIGINAL_BANK0_HEX="${DATARAM_DIR}/bank0.hex"
ORIGINAL_BANK1_HEX="${DATARAM_DIR}/bank1.hex"
ORIGINAL_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex"
ORIGINAL_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex"
BACKUP_BANK0_HEX="${DATARAM_DIR}/bank0.hex.original_backup"
BACKUP_BANK1_HEX="${DATARAM_DIR}/bank1.hex.original_backup"
BACKUP_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex.original_backup"
BACKUP_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex.original_backup"

if [ -f "${ORIGINAL_INST_HEX}" ]; then
  cp "${ORIGINAL_INST_HEX}" "${BACKUP_INST_HEX}"
fi

if [ -f "${ORIGINAL_BANK0_HEX}" ]; then
  cp "${ORIGINAL_BANK0_HEX}" "${BACKUP_BANK0_HEX}"
fi

if [ -f "${ORIGINAL_BANK1_HEX}" ]; then
  cp "${ORIGINAL_BANK1_HEX}" "${BACKUP_BANK1_HEX}"
fi

if [ -f "${ORIGINAL_INST_BANK0_HEX}" ]; then
  cp "${ORIGINAL_INST_BANK0_HEX}" "${BACKUP_INST_BANK0_HEX}"
fi

if [ -f "${ORIGINAL_INST_BANK1_HEX}" ]; then
  cp "${ORIGINAL_INST_BANK1_HEX}" "${BACKUP_INST_BANK1_HEX}"
fi

# Function to convert ELF to HEX (instruction memory)
elf_to_hex() {
  local elf_file=$1
  local hex_file=$2

  # Convert ELF to binary
  if ! riscv32-unknown-elf-objcopy -O binary "${elf_file}" "${hex_file}.bin" 2>/dev/null; then
    return 1
  fi

  # Convert binary to hex format (32-bit words, little-endian)
  od -An -tx4 -w4 -v "${hex_file}.bin" | awk '{print $1}' >"${hex_file}"

  # Clean up
  rm -f "${hex_file}.bin"
  return 0
}

# Function to extract data memory from ELF into bank0/bank1
extract_data_mem() {
  local elf_file=$1
  "${DATARAM_DIR}/extract_data.sh" "${elf_file}" "${DATARAM_DIR}" >/dev/null
  return $?
}

refresh_inst_banks() {
  "${DATARAM_DIR}/split_instrom_to_banks.sh" "${ORIGINAL_INST_HEX}" "${DATARAM_DIR}" >/dev/null
}

# Function to run a single test
run_single_test() {
  local test_file=$1
  local test_name=$(basename "${test_file}")

  printf "${CYAN}%-4d${NC} ${BLUE}%-40s${NC} " "$((TOTAL + 1))" "${test_name}"

  # Convert ELF to HEX (instruction memory)
  local temp_inst_hex="${INSTROM_DIR}/test_temp.hex"
  if ! elf_to_hex "${test_file}" "${temp_inst_hex}"; then
    echo -e "${YELLOW}SKIP${NC} (conversion failed)"
    echo "[SKIP] ${test_name}: ELF conversion failed" >>"${SUMMARY_FILE}"
    ((SKIPPED++))
    return
  fi

  # Extract data memory (bank0/bank1)
  extract_data_mem "${test_file}"

  # Replace instrom.hex with test hex file
  cp "${temp_inst_hex}" "${ORIGINAL_INST_HEX}"
  refresh_inst_banks

  # Run simulation with timeout
  local sim_log="${RESULTS_DIR}/${test_name}.log"
  cd "${SCRIPT_DIR}"

  if timeout 10s ./simv >"${sim_log}" 2>&1; then
    # Parse result
    if grep -q "TEST PASSED" "${sim_log}"; then
      local perf_line
      perf_line=$(grep '\[PERF\]' "${sim_log}" | tail -1 || true)
      if [ -n "${perf_line}" ]; then
        local mcycle minstret cpi
        mcycle=$(echo "${perf_line}" | sed -n 's/.*mcycle=\([0-9]*\).*/\1/p')
        minstret=$(echo "${perf_line}" | sed -n 's/.*minstret=\([0-9]*\).*/\1/p')
        cpi=$(echo "${perf_line}" | sed -n 's/.*cpi=\([0-9.]*\).*/\1/p')
        if [ -n "${mcycle}" ] && [ -n "${minstret}" ] && [ -n "${cpi}" ]; then
          echo -e "${GREEN}✓ PASS${NC} (mcycle=${mcycle} minstret=${minstret} cpi=${cpi})"
          echo "[PASS] ${test_name}" >>"${SUMMARY_FILE}"
          echo "[PERF] ${test_name}: mcycle=${mcycle} minstret=${minstret} cpi=${cpi}" >>"${SUMMARY_FILE}"
          PERF_SAMPLES=$((PERF_SAMPLES + 1))
          PERF_TOTAL_MCYCLE=$((PERF_TOTAL_MCYCLE + mcycle))
          PERF_TOTAL_MINSTRET=$((PERF_TOTAL_MINSTRET + minstret))
          PERF_CPI_SUM=$(awk -v a="${PERF_CPI_SUM}" -v b="${cpi}" 'BEGIN {printf "%.8f", a + b}')
        else
          echo -e "${GREEN}✓ PASS${NC} (perf=unparsed)"
          echo "[PASS] ${test_name}" >>"${SUMMARY_FILE}"
          echo "[PERF] ${test_name}: line='${perf_line}' (parse failed)" >>"${SUMMARY_FILE}"
        fi
      else
        echo -e "${GREEN}✓ PASS${NC} (perf=N/A)"
        echo "[PASS] ${test_name}" >>"${SUMMARY_FILE}"
      fi
      ((PASSED++))
    elif grep -q "TEST FAILED" "${sim_log}"; then
      local tohost=$(grep "TEST FAILED" "${sim_log}" | sed -n 's/.*tohost = *\([0-9]*\).*/\1/p')
      echo -e "${RED}✗ FAIL${NC} (tohost=${tohost})"
      echo "[FAIL] ${test_name}: tohost=${tohost}" >>"${SUMMARY_FILE}"
      echo "${test_name}" >>"${FAILED_TESTS_FILE}"
      ((FAILED++))
    else
      echo -e "${YELLOW}? UNKNOWN${NC}"
      echo "[UNKNOWN] ${test_name}: No clear result" >>"${SUMMARY_FILE}"
      echo "${test_name}" >>"${FAILED_TESTS_FILE}"
      ((FAILED++))
    fi
  else
    echo -e "${RED}⏱ TIMEOUT${NC}"
    echo "[TIMEOUT] ${test_name}: Simulation exceeded 10s" >>"${SUMMARY_FILE}"
    echo "${test_name}" >>"${FAILED_TESTS_FILE}"
    ((FAILED++))
  fi

  # Clean up
  rm -f "${temp_inst_hex}"

  ((TOTAL++))
}

# Find all matching tests
echo "Searching for tests matching: ${TEST_PATTERN}" | tee -a "${SUMMARY_FILE}"
test_files=$(find "${RISCV_TESTS_DIR}" -name "${TEST_PATTERN}" -type f ! -name "*.dump" | sort)

if [ -z "${test_files}" ]; then
  echo -e "${RED}No tests found matching pattern: ${TEST_PATTERN}${NC}"
  exit 1
fi

test_count=$(echo "${test_files}" | wc -l)
echo "Found ${test_count} tests" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"

# Run all tests
for test_file in ${test_files}; do
  test_name=$(basename "${test_file}")
  if [ -n "${SKIP_TEST_REGEX}" ] && [[ "${test_name}" =~ ${SKIP_TEST_REGEX} ]]; then
    printf "${CYAN}%-4d${NC} ${BLUE}%-40s${NC} ${YELLOW}SKIP${NC} (filtered)\n" "$((TOTAL + 1))" "${test_name}"
    echo "[SKIP] ${test_name}: filtered by SKIP_TEST_REGEX=${SKIP_TEST_REGEX}" >>"${SUMMARY_FILE}"
    ((SKIPPED++))
    ((TOTAL++))
    continue
  fi
  run_single_test "${test_file}"
done

# Restore original instrom.hex and bank hex files
if [ -f "${BACKUP_INST_HEX}" ]; then
  mv "${BACKUP_INST_HEX}" "${ORIGINAL_INST_HEX}"
fi

if [ -f "${BACKUP_BANK0_HEX}" ]; then
  mv "${BACKUP_BANK0_HEX}" "${ORIGINAL_BANK0_HEX}"
fi

if [ -f "${BACKUP_BANK1_HEX}" ]; then
  mv "${BACKUP_BANK1_HEX}" "${ORIGINAL_BANK1_HEX}"
fi

if [ -f "${BACKUP_INST_BANK0_HEX}" ]; then
  mv "${BACKUP_INST_BANK0_HEX}" "${ORIGINAL_INST_BANK0_HEX}"
fi

if [ -f "${BACKUP_INST_BANK1_HEX}" ]; then
  mv "${BACKUP_INST_BANK1_HEX}" "${ORIGINAL_INST_BANK1_HEX}"
fi

# Print summary
echo "" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Test Summary" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Total tests:   ${TOTAL}" | tee -a "${SUMMARY_FILE}"
echo -e "${GREEN}Passed:        ${PASSED}${NC}" | tee -a "${SUMMARY_FILE}"
echo -e "${RED}Failed:        ${FAILED}${NC}" | tee -a "${SUMMARY_FILE}"
echo -e "${YELLOW}Skipped:       ${SKIPPED}${NC}" | tee -a "${SUMMARY_FILE}"

if [ ${TOTAL} -gt 0 ]; then
  PASS_RATE=$((PASSED * 100 / TOTAL))
  echo "Pass rate:     ${PASS_RATE}%" | tee -a "${SUMMARY_FILE}"
fi

if [ ${PERF_SAMPLES} -gt 0 ]; then
  PERF_AVG_CPI=$(awk -v s="${PERF_CPI_SUM}" -v n="${PERF_SAMPLES}" 'BEGIN {printf "%.4f", s / n}')
  if [ ${PERF_TOTAL_MINSTRET} -gt 0 ]; then
    PERF_WEIGHTED_CPI=$(awk -v c="${PERF_TOTAL_MCYCLE}" -v i="${PERF_TOTAL_MINSTRET}" 'BEGIN {printf "%.4f", c / i}')
  else
    PERF_WEIGHTED_CPI="N/A"
  fi
  echo "Perf samples:  ${PERF_SAMPLES}" | tee -a "${SUMMARY_FILE}"
  echo "Total mcycle:  ${PERF_TOTAL_MCYCLE}" | tee -a "${SUMMARY_FILE}"
  echo "Total minstret:${PERF_TOTAL_MINSTRET}" | tee -a "${SUMMARY_FILE}"
  echo "Avg CPI:       ${PERF_AVG_CPI}" | tee -a "${SUMMARY_FILE}"
  echo "Weighted CPI:  ${PERF_WEIGHTED_CPI}" | tee -a "${SUMMARY_FILE}"
else
  echo "Perf samples:  0 (no [PERF] lines found in logs)" | tee -a "${SUMMARY_FILE}"
fi

echo "" | tee -a "${SUMMARY_FILE}"
echo "End time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"
echo "Results saved to: ${SUMMARY_FILE}" | tee -a "${SUMMARY_FILE}"

if [ ${FAILED} -gt 0 ]; then
  echo "Failed tests saved to: ${FAILED_TESTS_FILE}" | tee -a "${SUMMARY_FILE}"
fi

echo "Individual test logs in: ${RESULTS_DIR}/" | tee -a "${SUMMARY_FILE}"

# Exit with appropriate code
if [ ${FAILED} -gt 0 ]; then
  exit 1
else
  exit 0
fi
