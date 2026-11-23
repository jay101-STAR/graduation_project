#!/usr/bin/env python3
"""Legacy Lite endpoint units, then the current AXI4 CPU regression.
Use run_axi4.py to include AXI4 burst/fabric/arbiter units."""
from datetime import datetime
import os
from pathlib import Path
import subprocess
import sys

RTL = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RTL / "tests"))
import run_mem_handshake


def main():
    os.chdir(RTL)
    results = RTL / "test_results"
    results.mkdir(exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    build_dir = Path('/tmp/axi_ram_verilator')
    build_dir.mkdir(exist_ok=True)
    if "--binary" not in sys.argv and "--baseline" not in sys.argv:
        for bench, marker in (("axi_lite_master_tb", "[AXI-MASTER-UNIT] PASS"),
                              ("fetch_mem_adapter_tb", "[FETCH-UNIT] PASS"),
                              ("axi_ram_unit_tb", "[AXI-RAM-UNIT] PASS"),
                              ("lsu_unit_tb", "[LSU-UNIT] PASS")):
            directory = build_dir / bench
            directory.mkdir(exist_ok=True)
            sources = sorted(p for p in (RTL / 'vsrc').rglob('*')
                             if p.suffix in ('.v', '.sv') and p.name != 'testbench.v')
            log = results / f"{bench}_{stamp}.log"
            with log.with_suffix('.build.log').open('w') as output:
                subprocess.run(['verilator', '--binary', '--timing', '-Wno-fatal', '--top-module', bench,
                                '--Mdir', str(directory), '-j', '4', *map(str, sources),
                                str(RTL / f'tests/{bench}.sv')], check=True, timeout=180,
                               stdout=output, stderr=subprocess.STDOUT,
                               env={**os.environ, 'CCACHE_DIR': '/tmp/p1_ccache'})
            with log.open('w') as output:
                subprocess.run([str(directory / f'V{bench}')], check=True, timeout=30,
                               stdout=output, stderr=subprocess.STDOUT)
            if marker not in log.read_text():
                raise RuntimeError(f'Unit test did not pass: {log}')
            print(f'{bench}: PASS; {log}', flush=True)
    os.environ.setdefault('BP_TIMEOUT_NS', '200000000')
    sys.argv += ['--build-dir', str(build_dir), '--timeout-ns', '20000000']
    if '--baseline' not in sys.argv:
        sys.argv += ['--extra-checks', str(RTL / 'tests/axi_ram_checks.svh'), '--delay-master']
    if '--suite' not in sys.argv:
        sys.argv += ['--suite', 'focused', '--suite', 'axi']
    run_mem_handshake.main()


if __name__ == '__main__':
    main()
