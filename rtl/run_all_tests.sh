#!/bin/bash

# Unified regression runner:
# 1) Optional simv build
# 2) UART smoke tests
# 3) ISA regression via run_tests.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/test_results"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

PATTERN="rv32u[i,m]-p-*"
RISCV_SKIP_REGEX="^rv32ui-p-fence_i$"
NO_BUILD=0

while [ $# -gt 0 ]; do
  case "$1" in
    --no-build)
      NO_BUILD=1
      shift
      ;;
    --no-skip-fencei)
      RISCV_SKIP_REGEX=""
      shift
      ;;
    *)
      PATTERN="$1"
      shift
      ;;
  esac
done

mkdir -p "${RESULTS_DIR}"
SUMMARY_FILE="${RESULTS_DIR}/all_tests_summary_${TIMESTAMP}.txt"

TOTAL=0
PASSED=0
FAILED=0

echo "========================================" | tee "${SUMMARY_FILE}"
echo "Unified Test Runner" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Start time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "ISA pattern: ${PATTERN}" | tee -a "${SUMMARY_FILE}"
if [ -n "${RISCV_SKIP_REGEX}" ]; then
  echo "ISA skip regex: ${RISCV_SKIP_REGEX}" | tee -a "${SUMMARY_FILE}"
else
  echo "ISA skip regex: <none>" | tee -a "${SUMMARY_FILE}"
fi
echo "" | tee -a "${SUMMARY_FILE}"

run_step() {
  local name="$1"
  local cmd="$2"
  local log_file="${RESULTS_DIR}/all_tests_${TIMESTAMP}_${name}.log"

  TOTAL=$((TOTAL + 1))
  printf "[%02d] %-24s ... " "${TOTAL}" "${name}" | tee -a "${SUMMARY_FILE}"

  if bash -lc "cd '${SCRIPT_DIR}' && ${cmd}" >"${log_file}" 2>&1; then
    echo "PASS" | tee -a "${SUMMARY_FILE}"
    PASSED=$((PASSED + 1))
  else
    echo "FAIL" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
  fi
}

run_uart_test() {
  local name="$1"
  local asm_file="$2"
  local plusarg="$3"
  local log_file="${RESULTS_DIR}/all_tests_${TIMESTAMP}_${name}.log"

  TOTAL=$((TOTAL + 1))
  printf "[%02d] %-24s ... " "${TOTAL}" "${name}" | tee -a "${SUMMARY_FILE}"

  if [ ! -f "${SCRIPT_DIR}/simv" ]; then
    echo "FAIL" | tee -a "${SUMMARY_FILE}"
    echo "[ERROR] simv not found. Build first." >"${log_file}"
    FAILED=$((FAILED + 1))
    return
  fi

  if bash -lc "cd '${SCRIPT_DIR}' && \
      ./vsrc/instrom/llvm.sh '${asm_file}' && \
      cp '${asm_file%.s}.hex' ./vsrc/instrom/instrom.hex && \
      ./simv ${plusarg} +bp_pattern_test -l sim.log" >"${log_file}" 2>&1; then
    if rg -q "TEST PASSED" "${log_file}"; then
      echo "PASS" | tee -a "${SUMMARY_FILE}"
      PASSED=$((PASSED + 1))
    else
      echo "FAIL" | tee -a "${SUMMARY_FILE}"
      FAILED=$((FAILED + 1))
    fi
  else
    echo "FAIL" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
  fi
}

if [ "${NO_BUILD}" -eq 0 ]; then
  run_step "simv_build" "make simv_build"
else
  echo "[--] skip build (--no-build)" | tee -a "${SUMMARY_FILE}"
fi

# Backup and restore instrom.hex around all UART tests.
ORIGINAL_INST_HEX="${SCRIPT_DIR}/vsrc/instrom/instrom.hex"
BACKUP_INST_HEX="${SCRIPT_DIR}/vsrc/instrom/instrom.hex.all_tests_backup"
if [ -f "${ORIGINAL_INST_HEX}" ]; then
  cp "${ORIGINAL_INST_HEX}" "${BACKUP_INST_HEX}"
fi

run_uart_test "uart_tx_smoke" "./vsrc/instrom/uart_tx_smoke_test.s" "+uart_tx_smoke"
run_uart_test "uart_tx_back_to_back" "./vsrc/instrom/uart_tx_back_to_back_test.s" "+uart_tx_smoke"
run_uart_test "uart_loopback_echo" "./vsrc/instrom/uart_loopback_echo_test.s" "+uart_loopback_smoke"
run_uart_test "uart_rx_smoke" "./vsrc/instrom/uart_rx_smoke_test.s" "+uart_rx_smoke"
run_uart_test "uart_rx_double" "./vsrc/instrom/uart_rx_double_read_test.s" "+uart_rx_smoke"
run_uart_test "uart_rx_overrun" "./vsrc/instrom/uart_rx_overrun_test.s" "+uart_rx_overrun_smoke"

if [ -f "${BACKUP_INST_HEX}" ]; then
  mv "${BACKUP_INST_HEX}" "${ORIGINAL_INST_HEX}"
fi

if [ -n "${RISCV_SKIP_REGEX}" ]; then
  run_step "riscv_batch" "SKIP_TEST_REGEX='${RISCV_SKIP_REGEX}' ./run_tests.sh '${PATTERN}'"
else
  run_step "riscv_batch" "./run_tests.sh '${PATTERN}'"
fi

echo "" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Summary" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Total:  ${TOTAL}" | tee -a "${SUMMARY_FILE}"
echo "Pass:   ${PASSED}" | tee -a "${SUMMARY_FILE}"
echo "Fail:   ${FAILED}" | tee -a "${SUMMARY_FILE}"
echo "End:    $(date)" | tee -a "${SUMMARY_FILE}"
echo "Summary file: ${SUMMARY_FILE}" | tee -a "${SUMMARY_FILE}"
echo "Detail logs:  ${RESULTS_DIR}/all_tests_${TIMESTAMP}_*.log" | tee -a "${SUMMARY_FILE}"

if [ "${FAILED}" -ne 0 ]; then
  exit 1
fi
exit 0
