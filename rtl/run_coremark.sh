#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COREMARK_DIR="${PROJECT_DIR}/verification/coremark"
PORT_DIR="${COREMARK_DIR}/riscv_port"
BENCH_DIR="${PROJECT_DIR}/verification/riscv-tests/benchmarks/rv32im_build"
RTL_DIR="${PROJECT_DIR}/rtl"
INSTROM_HEX="${RTL_DIR}/vsrc/instrom/instrom.hex"
DATARAM_DIR="${RTL_DIR}/vsrc/dataram"
COE_GEN_SCRIPT="${DATARAM_DIR}/gen_banked_coe.py"
COREMARK_ELF="${COREMARK_DIR}/coremark.elf"

usage() {
  cat <<'EOF'
Usage:
  ./run_coremark.sh [ITERATIONS]

Environment variables:
  ITERATIONS    CoreMark iterations (default: 1)
  SKIP_BUILD    1 to skip "make simv_build" (default: 0)
  TB_TIMEOUT_NS testbench timeout in ns via +timeout_ns (default: 200000000)
  UART_PRINT    1 to enable UART text output in sim.log (default: 0)
  CORE_FREQ_HZ  Core clock in Hz for Iterations/Sec estimate (default: 50000000)
  SIM_ARGS      Extra args passed to simv (default: empty)
  SIM_TIMEOUT   Timeout seconds for simv, 0 means no timeout (default: 0)

Examples:
  ./run_coremark.sh
  ./run_coremark.sh 10
  UART_PRINT=1 ./run_coremark.sh
  ITERATIONS=100 SKIP_BUILD=1 ./run_coremark.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ITERATIONS="${ITERATIONS:-1}"
if [[ $# -eq 1 ]]; then
  ITERATIONS="$1"
elif [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

if ! [[ "${ITERATIONS}" =~ ^[0-9]+$ ]]; then
  echo "Error: ITERATIONS must be a non-negative integer, got '${ITERATIONS}'"
  exit 1
fi

SKIP_BUILD="${SKIP_BUILD:-0}"
TB_TIMEOUT_NS="${TB_TIMEOUT_NS:-200000000}"
UART_PRINT="${UART_PRINT:-0}"
CORE_FREQ_HZ="${CORE_FREQ_HZ:-50000000}"
SIM_ARGS="${SIM_ARGS:-}"
SIM_TIMEOUT="${SIM_TIMEOUT:-0}"

if ! [[ "${TB_TIMEOUT_NS}" =~ ^[0-9]+$ ]]; then
  echo "Error: TB_TIMEOUT_NS must be a non-negative integer, got '${TB_TIMEOUT_NS}'"
  exit 1
fi
if [[ "${UART_PRINT}" != "0" && "${UART_PRINT}" != "1" ]]; then
  echo "Error: UART_PRINT must be 0 or 1, got '${UART_PRINT}'"
  exit 1
fi
if ! [[ "${CORE_FREQ_HZ}" =~ ^[0-9]+$ ]]; then
  echo "Error: CORE_FREQ_HZ must be a non-negative integer, got '${CORE_FREQ_HZ}'"
  exit 1
fi

TB_TIMEOUT_ARG=""
if [[ "${TB_TIMEOUT_NS}" -gt 0 ]] && [[ "${SIM_ARGS}" != *"+timeout_ns="* ]]; then
  TB_TIMEOUT_ARG="+timeout_ns=${TB_TIMEOUT_NS}"
fi

UART_PRINT_ARG=""
if [[ "${UART_PRINT}" == "1" ]] && [[ "${SIM_ARGS}" != *"+uart_tx_print"* ]]; then
  UART_PRINT_ARG="+uart_tx_print"
fi

if ! command -v riscv32-unknown-elf-gcc >/dev/null 2>&1; then
  echo "Error: riscv32-unknown-elf-gcc not found in PATH"
  exit 1
fi

for f in \
  "${PORT_DIR}/core_portme.c" \
  "${PORT_DIR}/ee_printf.c" \
  "${BENCH_DIR}/syscalls_rv32im.c" \
  "${BENCH_DIR}/crt_rv32im.S" \
  "${BENCH_DIR}/link_rv32im.ld" \
  "${RTL_DIR}/vsrc/instrom/elf2hex.sh" \
  "${DATARAM_DIR}/split_instrom_to_banks.sh" \
  "${DATARAM_DIR}/extract_data.sh"; do
  if [[ ! -f "${f}" ]]; then
    echo "Error: required file not found: ${f}"
    exit 1
  fi
done

FLAGS_STR="-O2 -ffreestanding -nostdlib"

echo "[CoreMark] Building ELF (ITERATIONS=${ITERATIONS})..."
cd "${COREMARK_DIR}"
riscv32-unknown-elf-gcc \
  -march=rv32im_zicsr -mabi=ilp32 -O2 -ffreestanding -nostdlib \
  -DITERATIONS="${ITERATIONS}" -DFLAGS_STR="\"${FLAGS_STR}\"" \
  -I. -I"${PORT_DIR}" \
  core_list_join.c core_main.c core_matrix.c core_state.c core_util.c \
  "${PORT_DIR}/core_portme.c" "${PORT_DIR}/ee_printf.c" \
  "${BENCH_DIR}/syscalls_rv32im.c" "${BENCH_DIR}/crt_rv32im.S" \
  -T "${BENCH_DIR}/link_rv32im.ld" \
  -o "${COREMARK_ELF}"

echo "[CoreMark] Generating memory images..."
"${RTL_DIR}/vsrc/instrom/elf2hex.sh" "${COREMARK_ELF}" "${INSTROM_HEX}"
"${DATARAM_DIR}/split_instrom_to_banks.sh" "${INSTROM_HEX}" "${DATARAM_DIR}"
"${DATARAM_DIR}/extract_data.sh" "${COREMARK_ELF}" "${DATARAM_DIR}"
python3 "${COE_GEN_SCRIPT}"

cd "${RTL_DIR}"
if [[ "${SKIP_BUILD}" != "1" ]]; then
  echo "[CoreMark] Building simv..."
  make simv_build
fi

if [[ ! -x "${RTL_DIR}/simv" ]]; then
  echo "Error: ${RTL_DIR}/simv not found or not executable."
  echo "Hint: rerun without SKIP_BUILD=1."
  exit 1
fi

echo "[CoreMark] Running simulation..."
if [[ "${SIM_TIMEOUT}" =~ ^[0-9]+$ ]] && [[ "${SIM_TIMEOUT}" -gt 0 ]]; then
  timeout "${SIM_TIMEOUT}" ./simv ${TB_TIMEOUT_ARG} ${UART_PRINT_ARG} ${SIM_ARGS} -l sim.log
else
  ./simv ${TB_TIMEOUT_ARG} ${UART_PRINT_ARG} ${SIM_ARGS} -l sim.log
fi

echo "[CoreMark] Result summary:"
grep -E "TIMEOUT|\\[PERF\\]|\\[BP\\]|CoreMark|Iterations|Total ticks|Total time|Correct operation validated|Errors detected" sim.log || true

perf_mcycle="$(sed -n 's/.*\[PERF\] mcycle=\([0-9][0-9]*\).*/\1/p' sim.log | tail -n 1)"
if [[ -n "${perf_mcycle}" ]] && [[ "${perf_mcycle}" -gt 0 ]]; then
  coremark_per_mhz="$(awk -v iter="${ITERATIONS}" -v cyc="${perf_mcycle}" 'BEGIN { printf "%.6f", (iter * 1000000.0) / cyc }')"
  iter_per_sec="$(awk -v iter="${ITERATIONS}" -v cyc="${perf_mcycle}" -v hz="${CORE_FREQ_HZ}" 'BEGIN { printf "%.3f", (iter * hz) / cyc }')"
  echo "[CoreMark] Estimated Iterations/Sec: ${iter_per_sec} (@${CORE_FREQ_HZ} Hz)"
  echo "[CoreMark] Estimated CoreMark/MHz  : ${coremark_per_mhz}"
fi

if grep -q "TEST PASSED" sim.log; then
  exit 0
fi
if grep -qE "TEST FAILED|TIMEOUT" sim.log; then
  exit 1
fi
exit 2
