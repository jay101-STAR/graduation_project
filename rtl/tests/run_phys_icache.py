#!/usr/bin/env python3
"""Test icache_phys_word, including errors and FENCE.I."""
from datetime import datetime
import json
import os
from pathlib import Path
import subprocess

RTL = Path(__file__).resolve().parents[1]

def main():
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    prefix = RTL / "test_results" / f"phys_icache_{stamp}"
    prefix.parent.mkdir(exist_ok=True)
    build = Path(f"/tmp/phys_icache_{stamp}")
    sources = [RTL / name for name in ("vsrc/cache/icache.sv", "vsrc/mem/icache_phys_word.v",
               "vsrc/mem/mem_attr_decode.v", "tests/phys_icache_tb.sv")]
    with Path(str(prefix)+".build.log").open("w") as output:
        subprocess.run(["verilator", "--binary", "--timing", "--trace", "--trace-depth", "3",
                        "--unroll-count", "256", "-Wno-fatal", "--top-module", "phys_icache_tb",
                        "--Mdir", str(build), "-j", "4", *map(str, sources)],
                       cwd=RTL, check=True, timeout=180, stdout=output, stderr=subprocess.STDOUT,
                       env={**os.environ, "CCACHE_DIR": "/tmp/phys_icache_ccache"})
    log = Path(str(prefix)+".log")
    with log.open("w") as output:
        result = subprocess.run([str(build/"Vphys_icache_tb"), f"+wave={prefix}.vcd"],
                                cwd=RTL, stdout=output, stderr=subprocess.STDOUT, timeout=30)
    passed = result.returncode == 0 and "[PHYS-ICACHE] PASS" in log.read_text()
    Path(str(prefix)+".json").write_text(json.dumps({"passed": passed, "log": str(log),
                                                    "wave": str(prefix)+".vcd"}, indent=2)+"\n")
    print(log.read_text(), end="")
    print(f"Evidence: {prefix}")
    return 0 if passed else 1

if __name__ == "__main__":
    raise SystemExit(main())
