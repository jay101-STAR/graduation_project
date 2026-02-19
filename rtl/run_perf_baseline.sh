#!/bin/bash

# Performance baseline runner (mcycle/minstret/CPI)
# Usage:
#   ./run_perf_baseline.sh
#   ./run_perf_baseline.sh --build
#   ./run_perf_baseline.sh --tests "rv32ui-p-add rv32ui-p-lw rv32um-p-div"

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RISCV_TESTS_DIR="${SCRIPT_DIR}/../verification/riscv-tests/isa"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
DATARAM_DIR="${SCRIPT_DIR}/vsrc/dataram"
RESULTS_DIR="${SCRIPT_DIR}/test_results"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SUMMARY_FILE="${RESULTS_DIR}/perf_baseline_${TIMESTAMP}.txt"

FORCE_BUILD=0
CUSTOM_TESTS=""

DEFAULT_TESTS=(
  "rv32ui-p-add"
  "rv32ui-p-beq"
  "rv32ui-p-lw"
  "rv32ui-p-sw"
  "rv32um-p-mul"
  "rv32um-p-div"
)

print_usage() {
  echo "Usage:"
  echo "  ./run_perf_baseline.sh"
  echo "  ./run_perf_baseline.sh --build"
  echo "  ./run_perf_baseline.sh --tests \"rv32ui-p-add rv32ui-p-lw rv32um-p-div\""
}

elf_to_hex() {
  local elf_file="$1"
  local hex_file="$2"
  if ! riscv32-unknown-elf-objcopy -O binary "${elf_file}" "${hex_file}.bin" 2>/dev/null; then
    return 1
  fi
  od -An -tx4 -w4 -v "${hex_file}.bin" | awk '{print $1}' >"${hex_file}"
  rm -f "${hex_file}.bin"
  return 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)
      FORCE_BUILD=1
      shift
      ;;
    --tests)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --tests requires a quoted space-separated list"
        print_usage
        exit 1
      fi
      CUSTOM_TESTS="$2"
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

mkdir -p "${RESULTS_DIR}"

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
else
  echo "[INFO] Reusing existing simv (up-to-date)."
fi

if [[ -n "${CUSTOM_TESTS}" ]]; then
  IFS=' ' read -r -a TESTS <<< "${CUSTOM_TESTS}"
else
  TESTS=("${DEFAULT_TESTS[@]}")
fi

if [[ ${#TESTS[@]} -eq 0 ]]; then
  echo "Error: test list is empty"
  exit 1
fi

# Backup current memory images and restore on exit.
ORIGINAL_INST_HEX="${INSTROM_DIR}/instrom.hex"
BACKUP_INST_HEX="${INSTROM_DIR}/instrom.hex.perf_backup"
ORIGINAL_BANK0_HEX="${DATARAM_DIR}/bank0.hex"
ORIGINAL_BANK1_HEX="${DATARAM_DIR}/bank1.hex"
ORIGINAL_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex"
ORIGINAL_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex"
BACKUP_BANK0_HEX="${DATARAM_DIR}/bank0.hex.perf_backup"
BACKUP_BANK1_HEX="${DATARAM_DIR}/bank1.hex.perf_backup"
BACKUP_INST_BANK0_HEX="${DATARAM_DIR}/inst_bank0.hex.perf_backup"
BACKUP_INST_BANK1_HEX="${DATARAM_DIR}/inst_bank1.hex.perf_backup"

if [[ -f "${ORIGINAL_INST_HEX}" ]]; then
  cp "${ORIGINAL_INST_HEX}" "${BACKUP_INST_HEX}"
fi
if [[ -f "${ORIGINAL_BANK0_HEX}" ]]; then
  cp "${ORIGINAL_BANK0_HEX}" "${BACKUP_BANK0_HEX}"
fi
if [[ -f "${ORIGINAL_BANK1_HEX}" ]]; then
  cp "${ORIGINAL_BANK1_HEX}" "${BACKUP_BANK1_HEX}"
fi
if [[ -f "${ORIGINAL_INST_BANK0_HEX}" ]]; then
  cp "${ORIGINAL_INST_BANK0_HEX}" "${BACKUP_INST_BANK0_HEX}"
fi
if [[ -f "${ORIGINAL_INST_BANK1_HEX}" ]]; then
  cp "${ORIGINAL_INST_BANK1_HEX}" "${BACKUP_INST_BANK1_HEX}"
fi

restore_images() {
  if [[ -f "${BACKUP_INST_HEX}" ]]; then
    mv "${BACKUP_INST_HEX}" "${ORIGINAL_INST_HEX}"
  fi
  if [[ -f "${BACKUP_BANK0_HEX}" ]]; then
    mv "${BACKUP_BANK0_HEX}" "${ORIGINAL_BANK0_HEX}"
  fi
  if [[ -f "${BACKUP_BANK1_HEX}" ]]; then
    mv "${BACKUP_BANK1_HEX}" "${ORIGINAL_BANK1_HEX}"
  fi
  if [[ -f "${BACKUP_INST_BANK0_HEX}" ]]; then
    mv "${BACKUP_INST_BANK0_HEX}" "${ORIGINAL_INST_BANK0_HEX}"
  fi
  if [[ -f "${BACKUP_INST_BANK1_HEX}" ]]; then
    mv "${BACKUP_INST_BANK1_HEX}" "${ORIGINAL_INST_BANK1_HEX}"
  fi
}
trap restore_images EXIT

echo "========================================" | tee "${SUMMARY_FILE}"
echo "Performance Baseline Runner" | tee -a "${SUMMARY_FILE}"
echo "========================================" | tee -a "${SUMMARY_FILE}"
echo "Start time: $(date)" | tee -a "${SUMMARY_FILE}"
echo "Tests: ${TESTS[*]}" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"
echo "NAME                           RESULT    MCYCLE       MINSTRET     CPI" | tee -a "${SUMMARY_FILE}"
echo "------------------------------------------------------------------------" | tee -a "${SUMMARY_FILE}"

TOTAL=0
PASSED=0
FAILED=0

for test_name in "${TESTS[@]}"; do
  TOTAL=$((TOTAL + 1))
  test_log="${RESULTS_DIR}/${test_name}.perf.log"
  test_file="$(find "${RISCV_TESTS_DIR}" -name "${test_name}" -type f ! -name "*.dump" | head -1)"
  temp_hex="${INSTROM_DIR}/perf_temp.hex"

  if [[ -z "${test_file}" ]]; then
    printf "%-30s %-9s %-12s %-12s %s\n" "${test_name}" "NOT_FOUND" "-" "-" "N/A" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
    continue
  fi

  if ! elf_to_hex "${test_file}" "${temp_hex}"; then
    printf "%-30s %-9s %-12s %-12s %s\n" "${test_name}" "ELF_FAIL" "-" "-" "N/A" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
    continue
  fi

  cp "${temp_hex}" "${ORIGINAL_INST_HEX}"
  "${DATARAM_DIR}/split_instrom_to_banks.sh" "${ORIGINAL_INST_HEX}" "${DATARAM_DIR}" >/dev/null
  "${DATARAM_DIR}/extract_data.sh" "${test_file}" "${DATARAM_DIR}" >/dev/null
  rm -f "${temp_hex}"

  sim_rc=0
  (cd "${SCRIPT_DIR}" && timeout 120s ./simv +vcs+lic+wait >"${test_log}" 2>&1) || sim_rc=$?

  if [[ ${sim_rc} -ne 0 ]]; then
    if rg -qi "Failed to obtain license|Cannot connect to the license server" "${test_log}"; then
      printf "%-30s %-9s %-12s %-12s %s\n" "${test_name}" "LICENSE" "-" "-" "N/A" | tee -a "${SUMMARY_FILE}"
    elif [[ ${sim_rc} -eq 124 ]]; then
      printf "%-30s %-9s %-12s %-12s %s\n" "${test_name}" "TIMEOUT" "-" "-" "N/A" | tee -a "${SUMMARY_FILE}"
    else
      printf "%-30s %-9s %-12s %-12s %s\n" "${test_name}" "ERROR" "-" "-" "N/A" | tee -a "${SUMMARY_FILE}"
    fi
    FAILED=$((FAILED + 1))
    continue
  fi

  if ! rg -q "TEST PASSED" "${test_log}"; then
    printf "%-30s %-9s %-12s %-12s %s\n" "${test_name}" "FAIL" "-" "-" "N/A" | tee -a "${SUMMARY_FILE}"
    FAILED=$((FAILED + 1))
    continue
  fi

  perf_line="$(rg '\[PERF\]' "${test_log}" | tail -1 || true)"
  if [[ -n "${perf_line}" ]]; then
    mcycle="$(echo "${perf_line}" | sed -n 's/.*mcycle=\([0-9]*\).*/\1/p')"
    minstret="$(echo "${perf_line}" | sed -n 's/.*minstret=\([0-9]*\).*/\1/p')"
    cpi="$(echo "${perf_line}" | sed -n 's/.*cpi=\([0-9.]*\).*/\1/p')"
    if [[ -z "${mcycle}" ]]; then mcycle="-"; fi
    if [[ -z "${minstret}" ]]; then minstret="-"; fi
    if [[ -z "${cpi}" ]]; then cpi="N/A"; fi
  else
    mcycle="-"
    minstret="-"
    cpi="N/A"
  fi

  printf "%-30s %-9s %-12s %-12s %s\n" "${test_name}" "PASS" "${mcycle}" "${minstret}" "${cpi}" | tee -a "${SUMMARY_FILE}"
  PASSED=$((PASSED + 1))
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
