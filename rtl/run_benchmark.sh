#!/bin/bash

# Run benchmark on the RV32IM CPU
# Usage: ./run_benchmark.sh <benchmark_name>
# Available: multiply, median, towers, vvadd

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_DIR="${SCRIPT_DIR}/../verification/riscv-tests/benchmarks/rv32im_build/output"
INSTROM_DIR="${SCRIPT_DIR}/vsrc/instrom"
DATARAM_DIR="${SCRIPT_DIR}/vsrc/dataram"
MEM_TOOL="${DATARAM_DIR}/mem_image_tool.py"

# Check argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <benchmark_name>"
    echo "Available benchmarks: multiply, median, towers, vvadd"
    echo ""
    echo "Example: $0 multiply"
    exit 1
fi

BENCHMARK=$1
HEX_FILE="${BENCH_DIR}/${BENCHMARK}.hex"

# Check if benchmark exists
if [ ! -f "$HEX_FILE" ]; then
    echo -e "${RED}Error: Benchmark '$BENCHMARK' not found.${NC}"
    echo "Available benchmarks:"
    ls -1 ${BENCH_DIR}/*.hex 2>/dev/null | xargs -n1 basename | sed 's/.hex$//'
    exit 1
fi

# Backup original instrom.hex
BACKUP_FILE="${INSTROM_DIR}/instrom.hex.benchmark_backup"
BACKUP_BANK0="${DATARAM_DIR}/bank0.hex.benchmark_backup"
BACKUP_BANK1="${DATARAM_DIR}/bank1.hex.benchmark_backup"
if [ -f "${INSTROM_DIR}/instrom.hex" ]; then
    cp "${INSTROM_DIR}/instrom.hex" "$BACKUP_FILE"
fi
if [ -f "${DATARAM_DIR}/bank0.hex" ]; then
    cp "${DATARAM_DIR}/bank0.hex" "${BACKUP_BANK0}"
fi
if [ -f "${DATARAM_DIR}/bank1.hex" ]; then
    cp "${DATARAM_DIR}/bank1.hex" "${BACKUP_BANK1}"
fi

# Copy benchmark to instrom
echo -e "${YELLOW}Running benchmark: ${BENCHMARK}${NC}"
cp "$HEX_FILE" "${INSTROM_DIR}/instrom.hex"
python3 "${MEM_TOOL}" init-instrom --instrom "${INSTROM_DIR}/instrom.hex" --out-dir "${DATARAM_DIR}" >/dev/null

# Show benchmark size
INST_COUNT=$(wc -l < "$HEX_FILE")
echo "Instruction count: ${INST_COUNT} words"

# Check if simv exists
if [ ! -f "${SCRIPT_DIR}/simv" ]; then
    echo -e "${YELLOW}simv not found, compiling...${NC}"
    cd "${SCRIPT_DIR}"
    make comp
else
    # Run simulation
    cd "${SCRIPT_DIR}"
    echo "Running simulation..."
    timeout 60s ./simv -l sim.log 2>&1 || true
fi

# Check result
if grep -q "TEST PASSED" sim.log; then
    echo -e "${GREEN}*** BENCHMARK PASSED ***${NC}"
elif grep -q "TEST FAILED" sim.log; then
    TOHOST=$(grep "TEST FAILED" sim.log | sed -n 's/.*tohost = *\([0-9]*\).*/\1/p')
    echo -e "${RED}*** BENCHMARK FAILED *** (tohost = ${TOHOST})${NC}"
else
    echo -e "${YELLOW}*** RESULT UNKNOWN ***${NC}"
    echo "Check sim.log for details"
fi

# Restore original instrom.hex
if [ -f "$BACKUP_FILE" ]; then
    mv "$BACKUP_FILE" "${INSTROM_DIR}/instrom.hex"
fi
if [ -f "${BACKUP_BANK0}" ]; then
    mv "${BACKUP_BANK0}" "${DATARAM_DIR}/bank0.hex"
fi
if [ -f "${BACKUP_BANK1}" ]; then
    mv "${BACKUP_BANK1}" "${DATARAM_DIR}/bank1.hex"
fi

echo ""
echo "Log saved to: ${SCRIPT_DIR}/sim.log"
