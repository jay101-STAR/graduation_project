#!/bin/bash

# Branch prediction pattern test runner
# Usage:
#   ./run_bp_tests.sh
#   ./run_bp_tests.sh --build

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
BP_TEST_DIR="${INSTROM_DIR}/bp_tests"
RESULTS_DIR="${SCRIPT_DIR}/test_results"

FORCE_BUILD=0
if [[ "${1:-}" == "--build" ]]; then
  FORCE_BUILD=1
fi

if [[ ! -d "${BP_TEST_DIR}" ]]; then
  echo "Error: ${BP_TEST_DIR} not found"
  exit 1
fi

shopt -s nullglob
BP_TESTS=("${BP_TEST_DIR}"/*.s)
shopt -u nullglob

if [[ ${#BP_TESTS[@]} -eq 0 ]]; then
  echo "Error: no .s tests found under ${BP_TEST_DIR}"
  exit 1
fi

mkdir -p "${RESULTS_DIR}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SUMMARY_FILE="${RESULTS_DIR}/bp_summary_${TIMESTAMP}.txt"

ORIGINAL_INSTROM_HEX="${INSTROM_DIR}/instrom.hex"
BACKUP_INSTROM_HEX="${INSTROM_DIR}/instrom.hex.bp_backup"
DATARAM_DIR="${SCRIPT_DIR}/vsrc/dataram"
ORIGINAL_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex"
ORIGINAL_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex"
BACKUP_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex.bp_backup"
BACKUP_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex.bp_backup"

if [[ -f "${ORIGINAL_INSTROM_HEX}" ]]; then
  cp "${ORIGINAL_INSTROM_HEX}" "${BACKUP_INSTROM_HEX}"
fi
if [[ -f "${ORIGINAL_INST_BANK0_HEX}" ]]; then
  cp "${ORIGINAL_INST_BANK0_HEX}" "${BACKUP_INST_BANK0_HEX}"
fi
if [[ -f "${ORIGINAL_INST_BANK1_HEX}" ]]; then
  cp "${ORIGINAL_INST_BANK1_HEX}" "${BACKUP_INST_BANK1_HEX}"
fi

restore_instrom_hex() {
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
trap restore_instrom_hex EXIT

NEED_BUILD=0
if [[ ${FORCE_BUILD} -eq 1 || ! -x "${SCRIPT_DIR}/simv" ]]; then
  NEED_BUILD=1
elif find "${SCRIPT_DIR}/vsrc" -type f \( -name "*.v" -o -name "*.sv" \) -newer "${SCRIPT_DIR}/simv" | grep -q .; then
  NEED_BUILD=1
  echo "[INFO] RTL newer than simv, rebuilding..."
fi

if [[ ${NEED_BUILD} -eq 1 ]]; then
  echo "[INFO] Building simv..."
  if ! (cd "${SCRIPT_DIR}" && make simv_build); then
    echo "Error: simv build failed"
    exit 1
  fi
fi

echo "========================================" | tee "${SUMMARY_FILE}"
echo "Branch Prediction Pattern Test Runner" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Start time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "Test dir:   ${BP_TEST_DIR}" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

TOTAL_BRANCHES=0
TOTAL_MISPREDICT=0
TOTAL_TARGET_MISS=0

HAS_TIMEOUT=0
if command -v timeout >/dev/null 2>&1; then
  HAS_TIMEOUT=1
fi

for test_path in "${BP_TESTS[@]}"; do
  test_name="$(basename "${test_path}" .s)"
  test_hex="${BP_TEST_DIR}/${test_name}.hex"
  test_log="${RESULTS_DIR}/${test_name}.bp.log"

  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "[%02d/%02d] %s ... " "${TOTAL_TESTS}" "${#BP_TESTS[@]}" "${test_name}" | tee -a "${SUMMARY_FILE}"

  if ! (cd "${INSTROM_DIR}" && ./llvm.sh "bp_tests/${test_name}.s" >/dev/null); then
    echo "ASM_FAIL" | tee -a "${SUMMARY_FILE}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    continue
  fi

  if [[ ! -f "${test_hex}" ]]; then
    echo "HEX_MISSING" | tee -a "${SUMMARY_FILE}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    continue
  fi

  cp "${test_hex}" "${ORIGINAL_INSTROM_HEX}"
  "${DATARAM_DIR}/split_instrom_to_banks.sh" "${ORIGINAL_INSTROM_HEX}" "${DATARAM_DIR}" >/dev/null

  sim_rc=0
  if [[ ${HAS_TIMEOUT} -eq 1 ]]; then
    (cd "${SCRIPT_DIR}" && timeout 20s ./simv +bp_pattern_test >"${test_log}" 2>&1) || sim_rc=$?
  else
    (cd "${SCRIPT_DIR}" && ./simv +bp_pattern_test >"${test_log}" 2>&1) || sim_rc=$?
  fi

  if [[ ${sim_rc} -ne 0 ]]; then
    if grep -qi "license" "${test_log}"; then
      echo "SIM_FAIL_LICENSE" | tee -a "${SUMMARY_FILE}"
    else
      echo "SIM_FAIL_OR_TIMEOUT" | tee -a "${SUMMARY_FILE}"
    fi
    FAILED_TESTS=$((FAILED_TESTS + 1))
    continue
  fi

  if ! grep -q "TEST PASSED" "${test_log}"; then
    echo "TEST_FAIL" | tee -a "${SUMMARY_FILE}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    continue
  fi

  bp_line="$(grep '\[BP\]' "${test_log}" | tail -1 || true)"
  if [[ -z "${bp_line}" ]]; then
    echo "NO_BP_STAT" | tee -a "${SUMMARY_FILE}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    continue
  fi

  parsed="$(echo "${bp_line}" | awk '
    {
      b=""; m=""; t="";
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^branches=/)   { split($i, a, "="); b = a[2]; }
        if ($i ~ /^mispredict=/) { split($i, a, "="); m = a[2]; }
        if ($i ~ /^target_miss=/){ split($i, a, "="); t = a[2]; }
      }
      if (b != "" && m != "" && t != "") {
        printf "%s %s %s", b, m, t;
      }
    }')"

  if [[ -z "${parsed}" ]]; then
    echo "BP_PARSE_FAIL" | tee -a "${SUMMARY_FILE}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    continue
  fi

  read -r branches mispredict target_miss <<< "${parsed}"

  acc="$(awk -v b="${branches}" -v m="${mispredict}" 'BEGIN {
    if (b > 0) printf "%.2f", (1.0 - (m / b)) * 100.0;
    else printf "N/A";
  }')"

  TOTAL_BRANCHES=$((TOTAL_BRANCHES + branches))
  TOTAL_MISPREDICT=$((TOTAL_MISPREDICT + mispredict))
  TOTAL_TARGET_MISS=$((TOTAL_TARGET_MISS + target_miss))
  PASSED_TESTS=$((PASSED_TESTS + 1))

  echo "PASS branches=${branches} mispredict=${mispredict} target_miss=${target_miss} acc=${acc}%" | tee -a "${SUMMARY_FILE}"
done

echo "" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Summary" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Total tests:    ${TOTAL_TESTS}" | tee -a "${SUMMARY_FILE}"
echo "Passed tests:   ${PASSED_TESTS}" | tee -a "${SUMMARY_FILE}"
echo "Failed tests:   ${FAILED_TESTS}" | tee -a "${SUMMARY_FILE}"
echo "Total branches: ${TOTAL_BRANCHES}" | tee -a "${SUMMARY_FILE}"
echo "Total miss:     ${TOTAL_MISPREDICT}" | tee -a "${SUMMARY_FILE}"
echo "Total tgt miss: ${TOTAL_TARGET_MISS}" | tee -a "${SUMMARY_FILE}"

if [[ ${TOTAL_BRANCHES} -gt 0 ]]; then
  WEIGHTED_ACC="$(awk -v b="${TOTAL_BRANCHES}" -v m="${TOTAL_MISPREDICT}" 'BEGIN {
    printf "%.2f", (1.0 - (m / b)) * 100.0;
  }')"
  DIRECTION_MISS=$((TOTAL_MISPREDICT - TOTAL_TARGET_MISS))
  DIRECTION_MISS_RATE="$(awk -v b="${TOTAL_BRANCHES}" -v d="${DIRECTION_MISS}" 'BEGIN {
    printf "%.2f", (d / b) * 100.0;
  }')"
  TARGET_MISS_RATE="$(awk -v b="${TOTAL_BRANCHES}" -v t="${TOTAL_TARGET_MISS}" 'BEGIN {
    printf "%.2f", (t / b) * 100.0;
  }')"

  echo "Weighted acc:   ${WEIGHTED_ACC}%" | tee -a "${SUMMARY_FILE}"
  echo "Dir miss rate:  ${DIRECTION_MISS_RATE}%" | tee -a "${SUMMARY_FILE}"
  echo "Tgt miss rate:  ${TARGET_MISS_RATE}%" | tee -a "${SUMMARY_FILE}"
fi

echo "" | tee -a "${SUMMARY_FILE}"
echo "Summary file: ${SUMMARY_FILE}" | tee -a "${SUMMARY_FILE}"

if [[ ${FAILED_TESTS} -gt 0 ]]; then
  exit 1
fi
exit 0
