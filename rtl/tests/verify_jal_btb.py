#!/usr/bin/env python3
"""JAL BTB validation; default simulator is VCS, with explicit Verilator fallback."""
import argparse
from datetime import datetime
import fcntl
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile

RTL = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RTL / "tools"))
import run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", choices=("vcs", "verilator"), default="vcs")
    parser.add_argument("--baseline-dir", type=Path)
    parser.add_argument("--reuse-build", action="store_true")
    parser.add_argument("--focused-only", action="store_true")
    args = parser.parse_args()
    os.chdir(RTL)
    baseline = args.baseline_dir.resolve() if args.baseline_dir else None
    stage = "before" if baseline else "after"
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results = RTL / "test_results"
    results.mkdir(exist_ok=True)
    build_dir = Path(f"/tmp/jal_btb_{args.simulator}_{stage}")
    build_dir.mkdir(exist_ok=True)
    binary = build_dir / ("Vtestbench" if args.simulator == "verilator" else "simv")
    env = {**os.environ, "CCACHE_DIR": "/tmp/div_once_ccache"}

    def compile_top(sources, top, directory, trace=False):
        if args.simulator == "verilator":
            command = ["verilator", "--binary", "--timing", "-Wno-fatal",
                       "--top-module", top, "--Mdir", str(directory), "-j", "4"]
            if trace:
                command += ["--trace", "--trace-depth", "5"]
            command += list(map(str, sources))
        else:
            # Reuse the repository's VCS/FSDB/compiler options, replacing sources.
            command = shlex.split(subprocess.check_output(
                ["make", "-n", "simv_build"], text=True, cwd=RTL))
            command = [part for part in command if not part.endswith((".v", ".sv"))]
            command += [*map(str, sources), "-top", top, "-o", str(directory / "simv"),
                        f"-Mdir={directory / 'csrc'}"]
        log = results / f"jal_btb_{stage}_{args.simulator}_{top}_{stamp}_build.log"
        print(f"Build {top}: {log}", flush=True)
        with log.open("w") as output:
            subprocess.run(command, cwd=RTL, env=env, check=True,
                           stdout=output, stderr=subprocess.STDOUT, timeout=180)

    if not args.reuse_build:
        if not baseline:
            unit_dir = build_dir / "unit"
            unit_dir.mkdir(exist_ok=True)
            compile_top([RTL / "vsrc/core/branch_predictor.v", RTL / "tests/jal_btb_unit_tb.sv"],
                        "jal_btb_unit_tb", unit_dir)
            unit_binary = unit_dir / ("Vjal_btb_unit_tb" if args.simulator == "verilator" else "simv")
            log = results / f"jal_btb_unit_{args.simulator}_{stamp}.log"
            with log.open("w") as output:
                subprocess.run([str(unit_binary)], check=True, timeout=30,
                               stdout=output, stderr=subprocess.STDOUT, cwd=RTL)
            if "[JAL-BTB-UNIT] PASS" not in log.read_text():
                raise RuntimeError(f"Unit test did not pass: {log}")
            print(f"Predictor unit: PASS; {log}", flush=True)
        with tempfile.TemporaryDirectory(prefix="jal-btb-bench-") as temp:
            bench = Path(temp) / "testbench.v"
            original = (RTL / "vsrc/testbench.v").read_text()
            includes = [RTL / "tests/jal_btb_checks.svh"]
            if baseline:
                original = "`define JAL_BTB_BASELINE\n" + original
            else:
                includes.append(RTL / "tests/jal_early_checks.svh")
            index = original.rfind("endmodule")
            original = (original[:index] + "\n" +
                        "\n".join(f'`include "{path}"' for path in includes) +
                        "\n" + original[index:])
            if args.simulator == "verilator":
                original = re.sub(r"^.*\$fsdbDump(?:file|vars).*\n", "", original,
                                  flags=re.MULTILINE)
            bench.write_text(original)
            sources = sorted(path for path in (RTL / "vsrc").rglob("*.v")
                             if path.name != "testbench.v")
            if baseline:
                for name in ("riscv_core.v", "branch_predictor.v"):
                    sources.remove(RTL / f"vsrc/core/{name}")
                    sources.append(baseline / name)
            compile_top([*sources, bench], "testbench", build_dir, trace=True)
    if not binary.is_file():
        raise RuntimeError(f"Missing binary: {binary}")

    def simulate(log, plusargs, timeout):
        with log.open("w") as output:
            try:
                result = subprocess.run([str(binary), *plusargs], cwd=RTL,
                                        stdout=output, stderr=subprocess.STDOUT,
                                        timeout=timeout or None)
            except subprocess.TimeoutExpired:
                return "TIMEOUT", log.read_text(errors="replace")
        text = log.read_text(errors="replace")
        if re.search(r"Failed to obtain license|Cannot connect to the license server", text, re.I):
            return "LICENSE", text
        if result.returncode:
            return "SIM_ERROR", text
        if re.search(r"TEST FAILED|TIMEOUT|Fatal", text):
            return "FAIL", text
        return ("PASS" if "TEST PASSED" in text else "UNKNOWN"), text

    def custom(case, flags, name=None, wave=False, marker=None):
        log = results / f"jal_btb_{stage}_{name or case}_{stamp}.log"
        with run.restore_images():
            with log.with_suffix(".prepare.log").open("w") as output:
                source = RTL / ("vsrc/instrom/bp_tests/bp_jal.s" if case == "bp_jal"
                                else f"vsrc/instrom/{case}.s")
                with tempfile.TemporaryDirectory(prefix="jal-btb-image-") as temp:
                    elf = Path(temp) / "test.elf"
                    subprocess.run(["riscv32-unknown-elf-gcc", "-march=rv32im_zicsr_zifencei",
                                    "-mabi=ilp32", "-nostdlib", "-nostartfiles",
                                    "-Wl,--no-relax,-Ttext=0x80000000", str(source),
                                    "-o", str(elf)], check=True, stdout=output,
                                   stderr=subprocess.STDOUT)
                    run.prepare(elf, output=output)
            plusargs = ["+bp_pattern_test", *flags]
            if wave:
                plusargs.append(f"+jal_btb_wave={log.with_suffix('.vcd')}")
            status, text = simulate(log, plusargs, 30)
            print(f"{name or case}: {status}; {log}", flush=True)
            required = [marker] if marker else []
            if "+jal_btb_checks" in flags:
                required.append("[JAL-BTB-CHECKS] PASS")
            if "+jal_checks" in flags:
                required.append("[JAL-CHECKS] PASS")
            if status != "PASS" or any(item not in text for item in required):
                raise RuntimeError(text)

    # Use the same lock as the prior MUL/DIV/JAL validation helpers.
    with (results / ".divider_simulation.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        custom("bp_jal", ["+jal_btb_latency"] + ([] if baseline else ["+jal_btb_checks"]),
               wave=True, marker="[JAL-BTB-CHECKS] PASS")
        if not baseline:
            custom("bp_jal", ["+jal_btb_checks", "+jal_btb_corrupt"],
                   name="wrong_target", marker="[JAL-BTB-CHECKS] PASS")
            custom("bp_jal", ["+jal_btb_checks", "+jal_btb_waits"],
                   name="warm_stalls", marker="[JAL-BTB-CHECKS] PASS")
            custom("jal_early", ["+jal_checks", "+jal_btb_checks"], marker="[JAL-CHECKS] PASS")
            custom("jal_early", ["+jal_checks", "+jal_btb_checks", "+jal_inject_waits"],
                   name="cold_stalls", marker="[JAL-CHECKS] PASS")
            custom("jal_btb_fence", [])
            custom("mul_handshake", [])
            custom("div_handshake", [])
        if not args.focused_only:
            run.simulate = simulate
            run.build = lambda _args, _log: None
            suites = [["coremark", "1", "--no-build"]] if baseline else [
                ["single", "rv32ui-p-jal", "--no-build"],
                ["single", "rv32ui-p-jalr", "--no-build"],
                ["bp", "--no-build"], ["minstret", "--no-build"],
                ["all", "--no-build"], ["coremark", "1", "--no-build"]]
            for suite in suites:
                print(f"[{stage}/{args.simulator}] run.sh {' '.join(suite)}", flush=True)
                sys.argv = ["run.sh", *suite]
                if run.main():
                    raise RuntimeError(f"Failed suite: {suite}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        sys.exit(1)
