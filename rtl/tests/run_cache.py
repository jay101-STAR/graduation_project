#!/usr/bin/env python3
"""AXI4 cache boundary tests and CPU regression: cache-mode bits are I/D.

00=bypass, 10=ICache, 01=DCache, 11=both caches enabled.
"""
import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import subprocess
import sys

RTL = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RTL / "tests"))
import run_mem_handshake


def main():
    cli = argparse.ArgumentParser(description=__doc__, add_help=False)
    cli.add_argument("--cache-mode", choices=("00", "10", "01", "11"), default="00")
    config, remaining = cli.parse_known_args()
    if "--icache-enable" in remaining or "--dcache-enable" in remaining:
        cli.error("select the caches using --cache-mode")
    if "--help" in remaining or "-h" in remaining:
        print(__doc__ + "\nAdditional option: --cache-mode {00,10,01,11}\n")
        sys.argv = [sys.argv[0], "--icache-enable", config.cache_mode[0], "--dcache-enable", config.cache_mode[1], *remaining]
        run_mem_handshake.main()
        return
    os.chdir(RTL)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    results = RTL / "test_results"
    results.mkdir(exist_ok=True)
    build = Path({"00": "/tmp/cache_c0_verilator", "10": "/tmp/cache_icache_verilator",
                  "01": "/tmp/cache_dcache_verilator", "11": "/tmp/cache_idcache_verilator"}[config.cache_mode])
    if "--build-dir" in remaining:
        build = Path(remaining[remaining.index("--build-dir") + 1]).resolve()
    build.mkdir(parents=True, exist_ok=True)
    units = []
    if config.cache_mode[0] == "1" and "--binary" not in remaining:
        subprocess.run([sys.executable, str(RTL / "tests/run_phys_icache.py")], check=True)
    if config.cache_mode[1] == "1" and "--binary" not in remaining:
        subprocess.run([sys.executable, str(RTL / "tests/run_phys_dcache.py")], check=True)
    if config.cache_mode == "00" and "--binary" not in remaining and "--baseline" not in remaining:
        specifications = [
            ("mem_attr_decode_tb", [], False),
            ("cache_boundary_tb", ["-GINSTRUCTION_PORT=0"], False),
            ("cache_boundary_tb", ["-GINSTRUCTION_PORT=1"], False),
            ("cache_boundary_tb", ["-GCACHE_ENABLE=1"], True),
            ("axi_lite_master_tb", [], False),
            ("fetch_mem_adapter_tb", [], False),
            ("axi_ram_unit_tb", [], False),
            ("lsu_unit_tb", [], False),
        ]
        sources = sorted(p for p in (RTL / "vsrc").rglob("*")
                         if p.suffix in (".v", ".sv") and p.name != "testbench.v")
        for index, (bench, parameters, expect_rejection) in enumerate(specifications):
            directory = build / f"unit_{index}_{bench}"
            directory.mkdir(exist_ok=True)
            log = results / f"c0_{bench}_{index}_{stamp}.log"
            with log.with_suffix(".build.log").open("w") as output:
                subprocess.run(["verilator", "--binary", "--timing", "--trace", "-Wno-fatal",
                                "--unroll-count", "256", "--top-module", bench, "--Mdir", str(directory), "-j", "4",
                                *parameters, *map(str, sources), str(RTL / f"tests/{bench}.sv")],
                               check=True, timeout=180, stdout=output, stderr=subprocess.STDOUT,
                               env={**os.environ, "CCACHE_DIR": "/tmp/p1_ccache"})
            flags = []
            if bench == "cache_boundary_tb" and not expect_rejection:
                flags = [f"+boundary_wave={results / f'c0_boundary_{index}_{stamp}.vcd'}"]
            with log.open("w") as output:
                status = subprocess.run([str(directory / f"V{bench}"), *flags], timeout=30,
                                        stdout=output, stderr=subprocess.STDOUT)
            contents = log.read_text()
            passed = ((status.returncode != 0 and "C0 supports CACHE_ENABLE=0 only" in contents)
                      if expect_rejection else status.returncode == 0 and "] PASS" in contents)
            units.append({"bench": bench, "parameters": parameters, "expected_rejection": expect_rejection,
                          "status": "PASS" if passed else "FAIL", "log": str(log)})
            (results / f"c0_units_{stamp}.json").write_text(json.dumps(units, indent=2) + "\n")
            if not passed:
                raise RuntimeError(f"Unit failed: {log}")
            print(f"C0 {bench} {parameters}: PASS; {log}", flush=True)
    if "--build-dir" not in remaining:
        remaining += ["--build-dir", str(build)]
    if "--suite" not in remaining:
        remaining += ["--suite", "focused", "--suite", "axi"]
    if "--timeout-ns" not in remaining:
        remaining += ["--timeout-ns", "20000000"]
    os.environ.setdefault("BP_TIMEOUT_NS", "200000000")
    if "--baseline" not in remaining:
        remaining += ["--extra-checks", str(RTL / "tests/axi_ram_checks.svh"),
                      "--extra-checks", str(RTL / "tests/cache_checks.svh"), "--delay-master"]
    sys.argv = [sys.argv[0], "--icache-enable", config.cache_mode[0], "--dcache-enable", config.cache_mode[1], *remaining]
    run_mem_handshake.main()


if __name__ == "__main__":
    main()
