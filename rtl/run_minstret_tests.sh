#!/bin/bash

# minstret regression runner
# Usage:
#   ./run_minstret_tests.sh
#   ./run_minstret_tests.sh --test <name>
#   ./run_minstret_tests.sh --build --test <name>   # --build is kept for compatibility

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
TEST_DIR="${INSTROM_DIR}/minstret_tests"
DATARAM_DIR="${SCRIPT_DIR}/vsrc/dataram"
RESULTS_DIR="${SCRIPT_DIR}/test_results"

LEGACY_BUILD_FLAG=0
TEST_FILTER=""

print_usage() {
  echo "Usage:"
  echo "  ./run_minstret_tests.sh                  # always rebuild simv"
  echo "  ./run_minstret_tests.sh --test <name>"
  echo "  ./run_minstret_tests.sh --build --test <name>   # --build is compatibility-only"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)
      LEGACY_BUILD_FLAG=1
      shift
      ;;
    --test)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --test requires a test name"
        print_usage
        exit 1
      fi
      TEST_FILTER="${2%.s}"
      shift 2
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

if [[ ! -d "${TEST_DIR}" ]]; then
  echo "Error: ${TEST_DIR} not found"
  exit 1
fi

if [[ -n "${TEST_FILTER}" ]]; then
  TEST_PATH="${TEST_DIR}/${TEST_FILTER}.s"
  if [[ ! -f "${TEST_PATH}" ]]; then
    echo "Error: test '${TEST_FILTER}' not found under ${TEST_DIR}"
    echo "Available tests:"
    shopt -s nullglob
    AVAILABLE_TESTS=("${TEST_DIR}"/*.s)
    shopt -u nullglob
    for t in "${AVAILABLE_TESTS[@]}"; do
      echo "  - $(basename "${t}" .s)"
    done
    exit 1
  fi
  TESTS=("${TEST_PATH}")
else
  shopt -s nullglob
  TESTS=("${TEST_DIR}"/*.s)
  shopt -u nullglob
fi

if [[ ${#TESTS[@]} -eq 0 ]]; then
  echo "Error: no .s tests found under ${TEST_DIR}"
  exit 1
fi

mkdir -p "${RESULTS_DIR}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SUMMARY_FILE="${RESULTS_DIR}/minstret_summary_${TIMESTAMP}.txt"

ORIGINAL_INSTROM_HEX="${INSTROM_DIR}/instrom.hex"
BACKUP_INSTROM_HEX="${INSTROM_DIR}/instrom.hex.minstret_backup"
ORIGINAL_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex"
ORIGINAL_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex"
BACKUP_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex.minstret_backup"
BACKUP_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex.minstret_backup"

if [[ -f "${ORIGINAL_INSTROM_HEX}" ]]; then
  cp "${ORIGINAL_INSTROM_HEX}" "${BACKUP_INSTROM_HEX}"
fi
if [[ -f "${ORIGINAL_INST_BANK0_HEX}" ]]; then
  cp "${ORIGINAL_INST_BANK0_HEX}" "${BACKUP_INST_BANK0_HEX}"
fi
if [[ -f "${ORIGINAL_INST_BANK1_HEX}" ]]; then
  cp "${ORIGINAL_INST_BANK1_HEX}" "${BACKUP_INST_BANK1_HEX}"
fi

restore_hex() {
  if [[ -f "${BACKUP_INSTROM_HEX}" ]]; then
    mv "${BACKUP_INSTROM_HEX}" "${ORIGINAL_INSTROM_HEX}"
  fi
  if [[ -f "${BACKUP_INST_BANK0_HEX}" ]]; then
    mv "${BACKUP_INST_BANK0_HEX}" "${ORIGINAL_INST_BANK0_HEX}"
  fi
  if [[ -f "${BACKUP_INST_BANK1_HEX}" ]]; then
    mv "${BACKUP_INST_BANK1_HEX}" "${ORIGINAL_INST_BANK1_HEX}"
  fi
}
trap restore_hex EXIT

if [[ ${LEGACY_BUILD_FLAG} -eq 1 ]]; then
  echo "[INFO] --build is now the default behavior; continuing."
fi

echo "[INFO] Building simv..."
if ! (cd "${SCRIPT_DIR}" && make simv_build); then
  echo "Error: simv build failed"
  exit 1
fi

echo "========================================" | tee "${SUMMARY_FILE}"
echo "minstret Regression Runner" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Start time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "Test dir:   ${TEST_DIR}" | tee -a "${SUMMARY_FILE}"
if [[ -n "${TEST_FILTER}" ]]; then
  echo "Test name:  ${TEST_FILTER}" | tee -a "${SUMMARY_FILE}"
else
  echo "Test name:  <all>" | tee -a "${SUMMARY_FILE}"
fi
echo "" | tee -a "${SUMMARY_FILE}"

TOTAL=0
PASSED=0
FAILED=0

HAS_TIMEOUT=0
if command -v timeout >/dev/null 2>&1; then
  HAS_TIMEOUT=1
fi

for test_path in "${TESTS[@]}"; do
  test_name="$(basename "${test_path}" .s)"
  test_hex="${TEST_DIR}/${test_name}.hex"
  test_log="${RESULTS_DIR}/${test_name}.minstret.log"

  TOTAL=$((TOTAL + 1))
  printf "[%02d/%02d] %s ... " "${TOTAL}" "${#TESTS[@]}" "${test_name}" | tee -a "${SUMMARY_FILE}"

  if ! (cd "${INSTROM_DIR}" && ./llvm.sh "minstret_tests/${test_name}.s" >/dev/null); then
    echo "ASM_FAIL" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
    continue
  fi

  if [[ ! -f "${test_hex}" ]]; then
    echo "HEX_MISSING" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
    continue
  fi

  cp "${test_hex}" "${ORIGINAL_INSTROM_HEX}"
  "${DATARAM_DIR}/split_instrom_to_banks.sh" "${ORIGINAL_INSTROM_HEX}" "${DATARAM_DIR}" >/dev/null

  sim_rc=0
  if [[ ${HAS_TIMEOUT} -eq 1 ]]; then
    (cd "${SCRIPT_DIR}" && timeout 120s ./simv +vcs+lic+wait >"${test_log}" 2>&1) || sim_rc=$?
  else
    (cd "${SCRIPT_DIR}" && ./simv +vcs+lic+wait >"${test_log}" 2>&1) || sim_rc=$?
  fi

  if [[ ${sim_rc} -ne 0 ]]; then
    if rg -qi "Failed to obtain license|Cannot connect to the license server" "${test_log}"; then
      echo "SIM_FAIL_LICENSE" | tee -a "${SUMMARY_FILE}"
    else
      echo "SIM_FAIL_OR_TIMEOUT" | tee -a "${SUMMARY_FILE}"
    fi
    FAILED=$((FAILED + 1))
    continue
  fi

  if rg -q "TEST PASSED" "${test_log}"; then
    echo "PASS" | tee -a "${SUMMARY_FILE}"
    PASSED=$((PASSED + 1))
  else
    echo "FAIL" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
  fi
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

if [[ ${FAILED} -ne 0 ]]; then
  exit 1
fi
exit 0
