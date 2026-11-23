#!/usr/bin/env python3
"""Validate request/response integration using the existing regression runner."""
import argparse
from datetime import datetime
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

RTL = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RTL / "tools"))
import run


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--binary", type=Path, help="Reuse a compiled baseline or handshake simulator")
    cli.add_argument("--baseline", action="store_true")
    cli.add_argument("--icache-enable", type=int, choices=(0, 1), default=1)
    cli.add_argument("--dcache-enable", type=int, choices=(0, 1), default=0)
    cli.add_argument("--suite", action="append", choices=("focused", "pipeline", "axi", "cache", "all", "bp", "minstret", "perf", "coremark"))
    cli.add_argument("--delay", type=int, default=0)
    cli.add_argument("--seed", type=int, default=1)
    cli.add_argument("--wave", type=Path, help="Dump the first simulation to this VCD")
    cli.add_argument("--build-dir", type=Path, default=Path('/tmp/p1_handshake_verilator'))
    cli.add_argument("--extra-checks", type=Path, action="append", default=[])
    cli.add_argument("--delay-master", action="store_true", help="Delay the native master boundary and all five AXI4 channels")
    cli.add_argument("--timeout-ns", type=int, help="Default simulation budget; explicit case budgets take precedence")
    args = cli.parse_args()
    if not 0 <= args.delay <= 15 or not 1 <= args.seed <= 65535:
        cli.error("delay must be 0..15 and seed must be 1..65535")
    if args.baseline and (not args.binary or args.wave):
        cli.error("baseline requires --binary and cannot use --wave")
    os.chdir(RTL)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    results = RTL / "test_results"
    results.mkdir(exist_ok=True)
    # Deliberate waits need a larger cycle budget; retain caller overrides.
    os.environ.setdefault("BP_TIMEOUT_NS", str(10000000 * (args.delay + 1)))
    wave = args.wave.resolve() if args.wave else None
    if wave:
        wave.parent.mkdir(parents=True, exist_ok=True)
    manifest = results / f"p1_run_{stamp}.json"
    evidence = {"baseline": args.baseline, "delay": args.delay, "seed": args.seed,
                "delay_master": args.delay_master,
                "icache_enable": args.icache_enable,
                "dcache_enable": args.dcache_enable,
                "suites": args.suite or ["focused"], "simulations": []}
    binary = args.binary.resolve() if args.binary else args.build_dir.resolve() / 'Vtestbench'
    if not args.binary:
        build = binary.parent
        build.mkdir(exist_ok=True)
        unit = build / "unit"
        unit.mkdir(exist_ok=True)
        unit_log = results / f"p1_unit_{stamp}.log"
        with (results / f"p1_unit_build_{stamp}.log").open("w") as output:
            subprocess.run(["verilator", "--binary", "--timing", "-Wno-fatal",
                            "--top-module", "mem_req_adapter_tb", "--Mdir", str(unit), "-j", "4",
                            str(RTL / "vsrc/bus/mem_req_adapter.v"),
                            str(RTL / "tests/mem_req_adapter_tb.sv")], check=True,
                           stdout=output, stderr=subprocess.STDOUT, timeout=180,
                           env={**os.environ, "CCACHE_DIR": "/tmp/p1_ccache"})
        with unit_log.open("w") as output:
            subprocess.run([str(unit / "Vmem_req_adapter_tb")], check=True, timeout=10,
                           stdout=output, stderr=subprocess.STDOUT)
        if "[MEM-ADAPTER-UNIT] PASS" not in unit_log.read_text():
            raise RuntimeError(f"Unit test did not pass: {unit_log}")
        print(f"Adapter unit: PASS; {unit_log}", flush=True)
        with tempfile.TemporaryDirectory(prefix="p1-handshake-") as tmp:
            tmp = Path(tmp)
            adapter = (RTL / "vsrc/bus/mem_req_adapter.v").read_text()
            adapter = adapter.replace("module mem_req_adapter #", "module mem_req_adapter_impl #", 1)
            (tmp / "adapter.v").write_text(adapter)
            bench = re.sub(r"^.*\$fsdbDump(?:file|vars).*\n", "",
                           (RTL / "vsrc/testbench.v").read_text(), flags=re.MULTILINE)
            bench = bench.replace("  top top (", f"  top #(.ICACHE_ENABLE({args.icache_enable}), .DCACHE_ENABLE({args.dcache_enable})) top (")
            index = bench.rfind("endmodule")
            includes = [RTL / "tests/mem_handshake_checks.svh", *args.extra_checks]
            bench = (bench[:index] + ''.join(f'`include "{p.resolve()}"\n' for p in includes) + bench[index:])
            (tmp / "testbench.v").write_text(bench)
            sources = sorted(p for p in (RTL / "vsrc").rglob("*")
                             if p.suffix in (".v", ".sv") and
                             p.name not in ("testbench.v", "mem_req_adapter.v"))
            sources += [tmp / "adapter.v", RTL / "tests/mem_req_delay.v", tmp / "testbench.v"]
            if args.delay_master:
                master = RTL / "vsrc/bus/axi4_master.v"
                sources.remove(master)
                (tmp / "master.v").write_text(master.read_text().replace(
                    "module axi4_master (", "module axi4_master_impl (", 1))
                sources += [tmp / "master.v", RTL / "tests/axi4_master_delay.v", RTL / "tests/axi4_channel_delay.sv"]
            log = results / f"p1_build_{stamp}.log"
            print(f"Build: {log}", flush=True)
            with log.open("w") as output:
                subprocess.run(["verilator", "--binary", "--timing", "--trace", "--trace-depth", "6",
                                "-Wno-fatal", "--unroll-count", "256", "--top-module", "testbench", "--Mdir", str(build), "-j", "4",
                                *map(str, sources)], check=True, stdout=output, stderr=subprocess.STDOUT,
                               env={**os.environ, "CCACHE_DIR": "/tmp/p1_ccache"}, timeout=180)
    if not binary.is_file():
        raise RuntimeError(f"Missing simulator: {binary}")
    evidence["binary"] = str(binary)

    def simulate(log, plusargs, timeout):
        nonlocal wave
        flags = [] if args.baseline else [f"+handshake_delay={args.delay}", f"+handshake_seed={args.seed}"]
        if not any(flag.startswith("+timeout_ns=") for flag in plusargs):
            if args.timeout_ns:
                flags.append(f"+timeout_ns={args.timeout_ns}")
            elif args.delay:
                flags.append(f"+timeout_ns={10000000 * (args.delay + 1)}")
        if wave:
            flags.append(f"+handshake_wave={wave}")
            wave = None
        status = "TIMEOUT"
        with log.open("w") as output:
            try:
                result = subprocess.run([str(binary), *plusargs, *flags], cwd=RTL,
                                        stdout=output, stderr=subprocess.STDOUT, timeout=timeout or None)
            except subprocess.TimeoutExpired:
                result = None
        text = log.read_text(errors="replace")
        if result:
            status = ("FAIL" if result.returncode or re.search(r"TEST FAILED|TIMEOUT|Fatal", text)
                      else "PASS" if "TEST PASSED" in text else "UNKNOWN")
        evidence["simulations"].append({"log": str(log), "status": status, "plusargs": plusargs + flags})
        manifest.write_text(json.dumps(evidence, indent=2) + "\n")
        return status, text

    run.simulate = simulate
    run.build = lambda _args, _log: None
    suites = args.suite or ["focused"]
    with (results / ".divider_simulation.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        for suite in suites:
            if suite in ("pipeline", "axi", "cache"):
                cases = (("axi_ram_uart",) if suite == "axi" else
                         ("cache_tests/dcache_cpu_smoke",) if suite == "cache" else
                         ("mul_handshake", "div_handshake", "jal_early", "jal_btb_fence"))
                for case in cases:
                    log = results / f"p1_{Path(case).name}_{stamp}.log"
                    with run.restore_images(), tempfile.TemporaryDirectory(prefix="p1-image-") as temp:
                        elf = Path(temp) / "test.elf"
                        with log.with_suffix(".prepare.log").open("w") as output:
                            subprocess.run(["riscv32-unknown-elf-gcc", "-march=rv32im_zicsr_zifencei",
                                            "-mabi=ilp32", "-nostdlib", "-nostartfiles",
                                            "-Wl,--no-relax,-Ttext=0x80000000",
                                            str(RTL / f"vsrc/instrom/{case}.s"), "-o", str(elf)],
                                           check=True, stdout=output, stderr=subprocess.STDOUT)
                            run.prepare(elf, output=output)
                        status, _ = simulate(log, ["+bp_pattern_test"], 30)
                    print(f"Pipeline {case}: {status}; {log}", flush=True)
                    if status != "PASS":
                        raise RuntimeError(f"Failed: {case}")
                continue
            commands = ([["single", name] for name in
                         ("rv32ui-p-lw", "rv32ui-p-sw", "rv32ui-p-fence_i", "rv32um-p-mul", "rv32um-p-div")]
                        if suite == "focused" else [[suite, "1"]] if suite == "coremark" else [[suite]])
            for command in commands:
                sys.argv = ["run.sh", *command, "--no-build"]
                print(f"P1 {command}, delay={args.delay}, seed={args.seed}, baseline={args.baseline}", flush=True)
                if run.main():
                    raise RuntimeError(f"Failed: {command}")
    print(f"Run manifest: {manifest}", flush=True)


if __name__ == "__main__":
    main()
