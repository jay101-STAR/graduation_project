#!/usr/bin/env python3
"""Run existing ISA/UART/CoreMark suites with Verilator for a CPU change.

Optional --baseline-div selects the old divider for a same-tool CoreMark baseline.
Only FSDB dumping is removed from a temporary copy of the existing testbench.
"""
import argparse
import fcntl
from datetime import datetime
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
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline-div", type=Path)
    parser.add_argument("--baseline-ex", type=Path)
    parser.add_argument("--baseline-core", type=Path)
    parser.add_argument("--baseline-id-ex", type=Path)
    parser.add_argument("--change", choices=("div_merge", "mul_n2", "div_n2", "jal_id"), default="div_merge")
    parser.add_argument("--reuse-build", action="store_true")
    args = parser.parse_args()
    os.chdir(RTL)
    if bool(args.baseline_ex) != bool(args.baseline_core):
        parser.error("--baseline-ex and --baseline-core must be provided together")
    if args.baseline_id_ex and not args.baseline_ex:
        parser.error("--baseline-id-ex requires --baseline-ex and --baseline-core")
    baseline = bool(args.baseline_div or args.baseline_ex)
    stage = "before" if baseline else "after"
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output = RTL / "test_results"
    output.mkdir(exist_ok=True)
    build_dir = Path(f"/tmp/{args.change}_{stage}")
    with tempfile.TemporaryDirectory(prefix="div-merge-tb-") as temp:
        bench = Path(temp) / "testbench.v"
        original = (RTL / "vsrc/testbench.v").read_text()
        if args.change == "jal_id":
            # Extra checks and optional VCD dumping belong only to this bench.
            index = original.rfind("endmodule")
            original = (original[:index] + '\n`include "' +
                        str(RTL / "tests/jal_early_checks.svh") + '"\n' + original[index:])
            if baseline:
                original = "`define JAL_ID_BASELINE\n" + original
        bench.write_text(re.sub(r"^.*\$fsdbDump(?:file|vars).*\n", "", original,
                                flags=re.MULTILINE))
        sources = sorted(str(p) for p in (RTL / "vsrc").rglob("*.v")
                         if p.name != "testbench.v")
        if args.baseline_div:
            sources.remove(str(RTL / "vsrc/core/div.v"))
            sources.append(str(args.baseline_div.resolve()))
        if args.baseline_ex:
            for name, replacement in (("ex.v", args.baseline_ex),
                                      ("riscv_core.v", args.baseline_core)):
                sources.remove(str(RTL / f"vsrc/core/{name}"))
                sources.append(str(replacement.resolve()))
        if args.baseline_id_ex:
            sources.remove(str(RTL / "vsrc/core/id_ex_reg.v"))
            sources.append(str(args.baseline_id_ex.resolve()))
        with (output / f"{args.change}_{stage}_{stamp}_build.log").open("w") as log:
            if not args.reuse_build:
                trace = ["--trace", "--trace-depth", "5"] if args.change == "jal_id" else []
                subprocess.run(["verilator", "--binary", "--timing", *trace, "-Wno-fatal",
                            "--top-module", "testbench", "--Mdir", str(build_dir),
                            "-j", "4", *sources, str(bench)], check=True,
                           stdout=log, stderr=subprocess.STDOUT,
                           env={**os.environ, "CCACHE_DIR": "/tmp/div_once_ccache"})

    def simulate(log, plusargs, timeout):
        with log.open("w") as stream:
            try:
                proc = subprocess.run([str(build_dir / "Vtestbench"), *plusargs],
                                      cwd=RTL, stdout=stream, stderr=subprocess.STDOUT,
                                      timeout=timeout or None)
            except subprocess.TimeoutExpired:
                return "TIMEOUT", log.read_text()
        text = log.read_text()
        if proc.returncode:
            return "SIM_ERROR", text
        if re.search(r"TEST FAILED|TIMEOUT", text):
            return "FAIL", text
        return ("PASS" if "TEST PASSED" in text else "UNKNOWN"), text

    run.simulate = simulate
    run.build = lambda args, log: None  # The exact selected RTL was built above.

    def prepare_case(case, stream):
        source = RTL / f"vsrc/instrom/{case}.s"
        if case in ("jal_once", "jal_early"):
            # These cases use la/CSR/FENCE.I. Resolve relocations before objcopy;
            # the legacy asm2hex helper copies an unlinked relocatable object.
            with tempfile.TemporaryDirectory(prefix="jal-image-") as temp:
                elf = Path(temp) / f"{case}.elf"
                subprocess.run(["riscv32-unknown-elf-gcc", "-march=rv32im_zicsr_zifencei",
                                "-mabi=ilp32", "-nostdlib", "-nostartfiles",
                                "-Wl,--no-relax,-Ttext=0x80000000", str(source),
                                "-o", str(elf)], check=True, stdout=stream,
                               stderr=subprocess.STDOUT)
                run.prepare(elf, output=stream)
        else:
            run.prepare(source, toolchain="gnu", output=stream)
    focused = {"mul_n2": "rv32um-p-mul", "jal_id": "rv32ui-p-jal"}.get(args.change, "rv32um-p-div")
    suites = [["coremark", "1", "--no-build"]] if baseline else [
        ["single", focused, "--no-build"],
        ["isa", "rv32um-p-*", "--no-build"],
        ["all", "--no-build"],
        ["coremark", "1", "--no-build"]]
    if args.change == "jal_id" and not baseline:
        suites = [["single", "rv32ui-p-jal", "--no-build"],
                  ["single", "rv32ui-p-jalr", "--no-build"],
                  ["bp", "--no-build"], ["minstret", "--no-build"],
                  ["all", "--no-build"], ["coremark", "1", "--no-build"]]
    # RAM images are shared by all simulators; serialize their preparation/runs.
    with (RTL / "test_results/.divider_simulation.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        custom_cases = []
        if not baseline and args.change in ("mul_n2", "div_n2"):
            custom_cases = ["mul_handshake"]
            if args.change == "div_n2":
                custom_cases.append("div_handshake")
        if args.change == "jal_id":
            # Both builds measure the same single-jump program. Directed checks
            # use the new metadata and run only against the current RTL.
            with run.restore_images():
                log = output / f"jal_once_{stage}_{stamp}.log"
                with log.with_suffix(".prepare.log").open("w") as stream:
                    prepare_case("jal_once", stream)
                wave = output / f"jal_once_{stage}_{stamp}.vcd"
                status, text = simulate(log, ["+bp_pattern_test", "+jal_once",
                                              f"+jal_wave={wave}"], 30)
                print(f"JAL target latency ({stage}): {status}; {log}", flush=True)
                if status != "PASS" or "[JAL-ONCE] TARGET" not in text:
                    raise SystemExit(text)
            if not baseline:
                custom_cases = ["jal_early", "mul_handshake", "div_handshake"]
        for case in custom_cases:
            with run.restore_images():
                log = output / f"{case}_{stamp}.log"
                with log.with_suffix(".prepare.log").open("w") as stream:
                    prepare_case(case, stream)
                extra = ["+jal_checks"] if case == "jal_early" else []
                status, text = simulate(log, ["+bp_pattern_test", *extra], 30)
                print(f"{case} dependency/mixed-operation assembly: {status}; {log}", flush=True)
                if status != "PASS" or (case == "jal_early" and "[JAL-CHECKS] PASS" not in text):
                    raise SystemExit(text)
                if case == "jal_early":
                    stall_log = output / f"jal_early_stalled_{stamp}.log"
                    status, text = simulate(stall_log, ["+bp_pattern_test", "+jal_checks",
                                                       "+jal_inject_waits"], 30)
                    print(f"JAL directed memory stalls: {status}; {stall_log}", flush=True)
                    if status != "PASS" or "[JAL-CHECKS] PASS" not in text:
                        raise SystemExit(text)
        for suite in suites:
            print(f"[{stage}] Existing runner: {' '.join(suite)}", flush=True)
            sys.argv = ["run.sh", *suite]
            if run.main():
                raise SystemExit(f"Failed suite: {suite}")


if __name__ == "__main__":
    main()
