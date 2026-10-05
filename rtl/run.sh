#!/bin/bash
# Single entry point for CPU tests, benchmarks and memory preparation.
set -euo pipefail
RTL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "${RTL_DIR}/tools/run.py" "$@"
