#!/usr/bin/env python3
"""Validate DCache/bypass routing, writeback, errors and clean maintenance."""
from datetime import datetime
import json
import os
from pathlib import Path
import resource
import subprocess

RTL = Path(__file__).resolve().parents[1]


def main():
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    prefix = RTL / "test_results" / f"phys_dcache_{stamp}"
    prefix.parent.mkdir(exist_ok=True)
    build = Path(f"/tmp/phys_dcache_{stamp}")
    sources = [RTL / name for name in ("vsrc/cache/dcache.sv", "vsrc/mem/dcache_phys_word.v",
               "vsrc/mem/mem_attr_decode.v", "tests/phys_dcache_tb.sv")]
    command = ["verilator", "--binary", "--timing", "--trace", "--trace-depth", "3",
               "--unroll-count", "256", "-Wno-fatal", "--top-module", "phys_dcache_tb",
               "--Mdir", str(build), "-j", "4", *map(str, sources)]
    with Path(str(prefix) + ".build.log").open("w") as output:
        subprocess.run(command, cwd=RTL, check=True, timeout=180, stdout=output,
                       stderr=subprocess.STDOUT,
                       env={**os.environ, "CCACHE_DIR": "/tmp/phys_dcache_ccache"})
    log = Path(str(prefix) + ".log")
    run = [str(build / "Vphys_dcache_tb"), f"+wave={prefix}.vcd"]
    with log.open("w") as output:
        result = subprocess.run(run, cwd=RTL, stdout=output, stderr=subprocess.STDOUT, timeout=30)
    passed = result.returncode == 0 and "[PHYS-DCACHE] PASS" in log.read_text()
    Path(str(prefix) + ".json").write_text(json.dumps({"passed": passed, "log": str(log),
        "wave": str(prefix) + ".vcd", "build_command": command, "command": run,
        "returncode": result.returncode}, indent=2) + "\n")
    print(log.read_text(), end="")
    print(f"Evidence: {prefix}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
