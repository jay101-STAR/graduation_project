#!/bin/bash

# UART-only regression runner
# Usage:
#   ./run_uart_tests.sh
#   ./run_uart_tests.sh --test uart_rx_smoke
#   ./run_uart_tests.sh --list
#   ./run_uart_tests.sh --build
#   ./run_uart_tests.sh --no-build --test uart_tx_smoke

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/test_results"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SUMMARY_FILE="${RESULTS_DIR}/uart_summary_${TIMESTAMP}.txt"

ALL_UART_TESTS=(
  "uart_tx_smoke"
  "uart_tx_back_to_back"
  "uart_loopback_echo"
  "uart_rx_smoke"
  "uart_rx_double"
  "uart_rx_overrun"
)

FORCE_BUILD=0
NO_BUILD=0
TEST_NAME=""
LIST_ONLY=0

print_usage() {
  echo "Usage:"
  echo "  ./run_uart_tests.sh"
  echo "  ./run_uart_tests.sh --test <name>"
  echo "  ./run_uart_tests.sh --list"
  echo "  ./run_uart_tests.sh --build"
  echo "  ./run_uart_tests.sh --no-build"
  echo ""
  echo "Available tests:"
  for t in "${ALL_UART_TESTS[@]}"; do
    echo "  - ${t}"
  done
}

resolve_uart_test() {
  local name="$1"
  case "${name}" in
    uart_tx_smoke)
      echo "./vsrc/instrom/uart_tx_smoke_test.s|+uart_tx_smoke"
      ;;
    uart_tx_back_to_back)
      echo "./vsrc/instrom/uart_tx_back_to_back_test.s|+uart_tx_smoke"
      ;;
    uart_loopback_echo)
      echo "./vsrc/instrom/uart_loopback_echo_test.s|+uart_loopback_smoke"
      ;;
    uart_rx_smoke)
      echo "./vsrc/instrom/uart_rx_smoke_test.s|+uart_rx_smoke"
      ;;
    uart_rx_double)
      echo "./vsrc/instrom/uart_rx_double_read_test.s|+uart_rx_smoke"
      ;;
    uart_rx_overrun)
      echo "./vsrc/instrom/uart_rx_overrun_test.s|+uart_rx_overrun_smoke"
      ;;
    *)
      return 1
      ;;
  esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    --build)
      FORCE_BUILD=1
      shift
      ;;
    --no-build)
      NO_BUILD=1
      shift
      ;;
    --test)
      if [ -z "${2:-}" ]; then
        echo "Error: --test requires a test name."
        print_usage
        exit 1
      fi
      TEST_NAME="$2"
      shift 2
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument '$1'"
      print_usage
      exit 1
      ;;
  esac
done

if [ "${FORCE_BUILD}" -eq 1 ] && [ "${NO_BUILD}" -eq 1 ]; then
  echo "Error: --build and --no-build cannot be used together."
  exit 1
fi

if [ "${LIST_ONLY}" -eq 1 ]; then
  for t in "${ALL_UART_TESTS[@]}"; do
    echo "${t}"
  done
  exit 0
fi

if [ -n "${TEST_NAME}" ]; then
  if ! resolve_uart_test "${TEST_NAME}" >/dev/null; then
    echo "Error: unknown test '${TEST_NAME}'"
    print_usage
    exit 1
  fi
  UART_TESTS=("${TEST_NAME}")
else
  UART_TESTS=("${ALL_UART_TESTS[@]}")
fi

mkdir -p "${RESULTS_DIR}"

echo "========================================" | tee "${SUMMARY_FILE}"
echo "UART Test Runner" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Start time: $(date)" | tee -a "${SUMMARY_FILE}"
if [ -n "${TEST_NAME}" ]; then
  echo "Run mode: single test (${TEST_NAME})" | tee -a "${SUMMARY_FILE}"
else
  echo "Run mode: all UART tests" | tee -a "${SUMMARY_FILE}"
fi
echo "" | tee -a "${SUMMARY_FILE}"

if [ "${NO_BUILD}" -eq 0 ]; then
  NEED_BUILD=0
  if [ "${FORCE_BUILD}" -eq 1 ] || [ ! -x "${SCRIPT_DIR}/simv" ]; then
    NEED_BUILD=1
  elif find "${SCRIPT_DIR}/vsrc" -type f \( -name "*.v" -o -name "*.sv" \) -newer "${SCRIPT_DIR}/simv" | grep -q .; then
    NEED_BUILD=1
    echo "[INFO] RTL newer than simv, rebuilding..." | tee -a "${SUMMARY_FILE}"
  fi

  if [ "${NEED_BUILD}" -eq 1 ]; then
    echo "[INFO] Building simv..." | tee -a "${SUMMARY_FILE}"
    if ! (cd "${SCRIPT_DIR}" && make simv_build >>"${SUMMARY_FILE}" 2>&1); then
      echo "Error: simv build failed" | tee -a "${SUMMARY_FILE}"
      exit 1
    fi
  else
    echo "[INFO] Reusing existing simv (up-to-date)." | tee -a "${SUMMARY_FILE}"
  fi
else
  echo "[INFO] Skip build (--no-build)." | tee -a "${SUMMARY_FILE}"
fi

ORIGINAL_INST_HEX="${SCRIPT_DIR}/vsrc/instrom/instrom.hex"
BACKUP_INST_HEX="${SCRIPT_DIR}/vsrc/instrom/instrom.hex.uart_backup"
ORIGINAL_BANK0_HEX="${SCRIPT_DIR}/vsrc/dataram/bank0.hex"
ORIGINAL_BANK1_HEX="${SCRIPT_DIR}/vsrc/dataram/bank1.hex"
BACKUP_BANK0_HEX="${SCRIPT_DIR}/vsrc/dataram/bank0.hex.uart_backup"
BACKUP_BANK1_HEX="${SCRIPT_DIR}/vsrc/dataram/bank1.hex.uart_backup"

if [ -f "${ORIGINAL_INST_HEX}" ]; then
  cp "${ORIGINAL_INST_HEX}" "${BACKUP_INST_HEX}"
fi
if [ -f "${ORIGINAL_BANK0_HEX}" ]; then
  cp "${ORIGINAL_BANK0_HEX}" "${BACKUP_BANK0_HEX}"
fi
if [ -f "${ORIGINAL_BANK1_HEX}" ]; then
  cp "${ORIGINAL_BANK1_HEX}" "${BACKUP_BANK1_HEX}"
fi

restore_images() {
  if [ -f "${BACKUP_INST_HEX}" ]; then
    mv "${BACKUP_INST_HEX}" "${ORIGINAL_INST_HEX}"
  fi
  if [ -f "${BACKUP_BANK0_HEX}" ]; then
    mv "${BACKUP_BANK0_HEX}" "${ORIGINAL_BANK0_HEX}"
  fi
  if [ -f "${BACKUP_BANK1_HEX}" ]; then
    mv "${BACKUP_BANK1_HEX}" "${ORIGINAL_BANK1_HEX}"
  fi
}
trap restore_images EXIT

TOTAL=0
PASSED=0
FAILED=0

run_uart_test() {
  local name="$1"
  local case_info asm_file plusarg
  local log_file="${RESULTS_DIR}/uart_${TIMESTAMP}_${name}.log"
  local sim_cmd

  case_info="$(resolve_uart_test "${name}")" || {
    TOTAL=$((TOTAL + 1))
    FAILED=$((FAILED + 1))
    printf "[%02d/%02d] %-22s ... FAIL\n" "${TOTAL}" "${#UART_TESTS[@]}" "${name}" | tee -a "${SUMMARY_FILE}"
    echo "[ERROR] unknown test '${name}'" >"${log_file}"
    return
  }

  IFS='|' read -r asm_file plusarg <<< "${case_info}"

  TOTAL=$((TOTAL + 1))
  printf "[%02d/%02d] %-22s ... " "${TOTAL}" "${#UART_TESTS[@]}" "${name}" | tee -a "${SUMMARY_FILE}"

  if [ ! -x "${SCRIPT_DIR}/simv" ]; then
    echo "FAIL" | tee -a "${SUMMARY_FILE}"
    echo "[ERROR] simv not found/executable." >"${log_file}"
    FAILED=$((FAILED + 1))
    return
  fi

  if command -v timeout >/dev/null 2>&1; then
    sim_cmd="timeout 30s ./simv ${plusarg} +bp_pattern_test -l sim.log"
  else
    sim_cmd="./simv ${plusarg} +bp_pattern_test -l sim.log"
  fi

  if bash -lc "cd '${SCRIPT_DIR}' && \
      ./vsrc/instrom/llvm.sh '${asm_file}' && \
      cp '${asm_file%.s}.hex' ./vsrc/instrom/instrom.hex && \
      python3 ./vsrc/dataram/mem_image_tool.py init-instrom --instrom ./vsrc/instrom/instrom.hex --out-dir ./vsrc/dataram && \
      python3 ./vsrc/dataram/mem_image_tool.py emit --dir ./vsrc/dataram && \
      ${sim_cmd}" >"${log_file}" 2>&1; then
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

for test_name in "${UART_TESTS[@]}"; do
  run_uart_test "${test_name}"
done

echo "" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Summary" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Total:  ${TOTAL}" | tee -a "${SUMMARY_FILE}"
echo "Pass:   ${PASSED}" | tee -a "${SUMMARY_FILE}"
echo "Fail:   ${FAILED}" | tee -a "${SUMMARY_FILE}"
echo "End:    $(date)" | tee -a "${SUMMARY_FILE}"
echo "Summary file: ${SUMMARY_FILE}" | tee -a "${SUMMARY_FILE}"
echo "Detail logs:  ${RESULTS_DIR}/uart_${TIMESTAMP}_*.log" | tee -a "${SUMMARY_FILE}"

if [ "${FAILED}" -ne 0 ]; then
  exit 1
fi
exit 0
