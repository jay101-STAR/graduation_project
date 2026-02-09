#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}"
COREMARK_DIR="${PROJECT_DIR}/verification/coremark"
PORT_DIR="${COREMARK_DIR}/riscv_port"
BENCH_DIR="${PROJECT_DIR}/verification/riscv-tests/benchmarks/rv32im_build"
INSTROM_HEX="${PROJECT_DIR}/rtl/vsrc/instrom/instrom.hex"
DATARAM_DIR="${PROJECT_DIR}/rtl/vsrc/dataram"

if [ ! -d "${COREMARK_DIR}" ]; then
  echo "Error: coremark directory not found: ${COREMARK_DIR}"
  exit 1
fi

if ! command -v riscv32-unknown-elf-gcc >/dev/null 2>&1; then
  echo "Error: riscv32-unknown-elf-gcc not found in PATH"
  exit 1
fi

ITERATIONS=${ITERATIONS:-1}
FLAGS_STR="-O2 -ffreestanding -nostdlib"

echo "Building CoreMark (ITERATIONS=${ITERATIONS})..."
cd "${COREMARK_DIR}"
riscv32-unknown-elf-gcc \
  -march=rv32im_zicsr -mabi=ilp32 -O2 -ffreestanding -nostdlib \
  -DITERATIONS=${ITERATIONS} -DFLAGS_STR="\"${FLAGS_STR}\"" \
  -I. -I"${PORT_DIR}" \
  core_list_join.c core_main.c core_matrix.c core_state.c core_util.c \
  "${PORT_DIR}/core_portme.c" "${PORT_DIR}/ee_printf.c" \
  "${BENCH_DIR}/syscalls_rv32im.c" \
  "${BENCH_DIR}/crt_rv32im.S" \
  -T "${BENCH_DIR}/link_rv32im.ld" \
  -o coremark.elf

echo "Generating HEX files..."
"${PROJECT_DIR}/rtl/vsrc/instrom/elf2hex.sh" "${COREMARK_DIR}/coremark.elf" "${INSTROM_HEX}"
"${PROJECT_DIR}/rtl/vsrc/dataram/extract_data.sh" "${COREMARK_DIR}/coremark.elf" "${DATARAM_DIR}"

echo "Running simulation..."
cd "${PROJECT_DIR}/rtl"
make simv_build
./simv -l sim.log
