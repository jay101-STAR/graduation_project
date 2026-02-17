#!/bin/bash

# Split instrom.hex (linear words) into interleaved bank init files.
# Usage: ./split_instrom_to_banks.sh [instrom_hex] [output_dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INST_HEX="${1:-${SCRIPT_DIR}/../instrom/instrom.hex}"
OUT_DIR="${2:-${SCRIPT_DIR}}"

BANK0_OUT="${OUT_DIR}/inst_bank0.hex"
BANK1_OUT="${OUT_DIR}/inst_bank1.hex"

if [ ! -f "${INST_HEX}" ]; then
  echo "Error: instruction hex not found: ${INST_HEX}" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"
: > "${BANK0_OUT}"
: > "${BANK1_OUT}"

word_addr=0
bank0_next=-1
bank1_next=-1

while IFS= read -r raw_line || [ -n "${raw_line}" ]; do
  line="${raw_line%%#*}"
  line="$(echo "${line}" | tr -d '[:space:]')"
  [ -z "${line}" ] && continue

  if [[ "${line}" == @* ]]; then
    addr_hex="${line#@}"
    word_addr=$((16#${addr_hex}))
    continue
  fi

  if (( (word_addr & 1) == 0 )); then
    bank_addr=$((word_addr >> 1))
    if (( bank0_next != bank_addr )); then
      printf "@%x\n" "${bank_addr}" >> "${BANK0_OUT}"
      bank0_next=${bank_addr}
    fi
    echo "${line}" >> "${BANK0_OUT}"
    bank0_next=$((bank0_next + 1))
  else
    bank_addr=$((word_addr >> 1))
    if (( bank1_next != bank_addr )); then
      printf "@%x\n" "${bank_addr}" >> "${BANK1_OUT}"
      bank1_next=${bank_addr}
    fi
    echo "${line}" >> "${BANK1_OUT}"
    bank1_next=$((bank1_next + 1))
  fi

  word_addr=$((word_addr + 1))
done < "${INST_HEX}"

echo "Generated:"
echo "  ${BANK0_OUT}"
echo "  ${BANK1_OUT}"
