#!/usr/bin/env python3
"""Generate single-division waveforms; restore the previous memory images."""
import argparse
from contextlib import contextmanager
import fcntl
from datetime import datetime
import os
from pathlib import Path
import subprocess
import sys

RTL = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RTL / "tools"))
from run import prepare, restore_images


@contextmanager
def serialized_images(output):
    with (output / ".divider_simulation.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        with restore_images():
            yield


def wave_setup(wave):
    scopes, signals = [], {}
    for line in wave.read_text().splitlines():
        fields = line.split()
        if not fields:
            continue
        if fields[0] == "$scope":
            scopes.append(fields[2])
        elif fields[0] == "$upscope":
            scopes.pop()
        elif fields[0] == "$var":
            signals[".".join(scopes + [fields[4]])] = (
                int(fields[2]), fields[3], fields[5] if len(fields) > 6 else "")
        elif fields[0] == "$enddefinitions":
            break
    core = "TOP.testbench.top.u_core."
    names = ["TOP.testbench.clk"] + [core + name for name in (
        "ex_valid", "id_ex_pc", "ex_is_div_instruction", "div_hazard",
        "stall_ex_dataram", "top_core_mem_stall", "ex_dataram_valid", "ex_dataram_rd_addr",
        "ex_dataram_alu_result", "ex0.div_start", "ex0.div_inflight",
        "ex0.div_done_raw", "ex0.div_done_latched", "ex0.div_result_valid",
        "ex0.div_result_accept", "ex0.ex_can_advance", "ex0.div0.current_state",
        "ex0.div0.cnt", "ex0.div0.div_skip_count", "ex0.div0.div_result_q",
        "ex0.div0.div_result_r")]
    setup = [f'[dumpfile] "{wave}"', "[timestart] 330"]
    for name in names:
        width, _, bounds = signals[name]
        setup += ["@28" if width == 1 else "@22", name + bounds]
    wave.with_suffix(".gtkw").write_text("\n".join(setup) + "\n")

    # Independently measure high intervals from VCD transitions, not bench logs.
    ids = {signals[core + name][1]: name for name in
           ("ex_is_div_instruction", "div_hazard")}
    start, intervals = {}, {name: [] for name in ids.values()}
    now = 0
    for line in wave.read_text().splitlines():
        if line.startswith("#"):
            now = int(line[1:])
        elif line and line[0] in "01" and line[1:] in ids:
            name = ids[line[1:]]
            if line[0] == "1":
                start[name] = now
            elif name in start:
                intervals[name].append((start.pop(name), now))
    return intervals


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--no-build", action="store_true")
    cli.add_argument("--full-iterations", action="store_true",
                     help="run only 100/3, with prefix skipping disabled in the testbench")
    cli.add_argument("--stall-tests", action="store_true",
                     help="also test memory waits around DIV completion")
    args = cli.parse_args()
    os.chdir(RTL)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output = RTL / "test_results"
    output.mkdir(exist_ok=True)
    binary = Path("/tmp/div_once_verilator/Vtestbench")
    if not args.no_build:
        sources = sorted(str(p) for p in (RTL / "vsrc").rglob("*.v")
                         if p.name != "testbench.v")
        with (output / f"div_once_{stamp}_build.log").open("w") as log:
            subprocess.run([
                "verilator", "--binary", "--timing", "--trace", "--trace-depth", "5",
                "-Wno-fatal", "--top-module", "testbench", "--Mdir",
                str(binary.parent), "-j", "4", *sources,
                str(RTL / "tests/div_once_tb.sv")], check=True, stdout=log,
                stderr=subprocess.STDOUT,
                env={**os.environ, "CCACHE_DIR": "/tmp/div_once_ccache"})
    results = []
    # label, assembly, quotient, remainder, ordinary latency, stall start, stall length
    cases = [("div_once", "div_once", 33, 1, 9, 0, 0),
             ("div_fast_once", "div_fast_once", 100, 0, 3, 0, 0),
             ("div_long_once", "div_long_once", 1431655765, 0, 33, 0, 0)]
    if args.full_iterations:
        cases = [("div_32_once", "div_once", 33, 1, 34, 0, 0)]
    if args.stall_tests:
        if args.full_iterations:
            cli.error("run --stall-tests separately from --full-iterations")
        cases += [("div_stall_early", "div_once", 33, 1, 9, 0, 2),
                  ("div_stall_completion", "div_once", 33, 1, 9, 7, 4),
                  ("div_stall_raw", "div_once", 33, 1, 9, 8, 4),
                  ("div_stall_long", "div_once", 33, 1, 9, 0, 12),
                  ("div_fast_stall", "div_fast_once", 100, 0, 3, 1, 4)]
    with serialized_images(output):
        for label, name, expected, remainder, latency, after, count in cases:
            expected_cycles = max(latency, after + count + 1) if count else latency
            prefix = output / f"{label}_{stamp}"
            with prefix.with_suffix(".prepare.log").open("w") as log:
                prepare(RTL / f"vsrc/instrom/{name}.s", toolchain="gnu", output=log)
            wave = prefix.with_suffix(".vcd")
            log_file = prefix.with_suffix(".log")
            with log_file.open("w") as log:
                extra = [f"+expected_remainder={remainder}", f"+expected_ex={expected_cycles}",
                         f"+stall_after={after}", f"+stall_cycles={count}"]
                if args.full_iterations:
                    extra.append("+full_iterations")
                subprocess.run([str(binary), f"+wave={wave}", f"+expected={expected}", *extra],
                               check=True, stdout=log, stderr=subprocess.STDOUT)
            text = log_file.read_text()
            if "TEST PASSED" not in text:
                raise RuntimeError(f"Test did not pass: {log_file}")
            intervals = wave_setup(wave)
            for signal, spans in intervals.items():
                if len(spans) != 1:
                    raise RuntimeError(f"Expected one high interval for {signal}: {spans}")
                expected_duration = expected_cycles if signal == "ex_is_div_instruction" else latency - 1
                if spans[0][1] - spans[0][0] != expected_duration * 20:
                    raise RuntimeError(f"Incorrect duration for {signal}: {spans}")
            result = f"{label}: {intervals}\n{next(x for x in text.splitlines() if 'TEST PASSED' in x)}"
            results.append(result)
            print(result)
            print(f"Wave: {wave}")
    (output / f"div_wave_summary_{stamp}.txt").write_text("\n\n".join(results) + "\n")


if __name__ == "__main__":
    main()
