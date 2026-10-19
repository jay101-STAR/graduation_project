#!/usr/bin/env python3
"""Measure MUL latency and verify result retention during memory backpressure."""
import argparse
from datetime import datetime
import os
from pathlib import Path
import subprocess
import sys

RTL = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RTL / "tools"))
from run import prepare
from run_div_once import serialized_images


def inspect_wave(wave, expected_cycles):
    scopes, signals = [], {}
    lines = wave.read_text().splitlines()
    for line in lines:
        parts = line.split()
        if not parts:
            continue
        if parts[0] == "$scope":
            scopes.append(parts[2])
        elif parts[0] == "$upscope":
            scopes.pop()
        elif parts[0] == "$var":
            signals[".".join(scopes + [parts[4]])] = (
                int(parts[2]), parts[3], parts[5] if len(parts) > 6 else "")
        elif parts[0] == "$enddefinitions":
            break
    core = "TOP.testbench.top.u_core."
    names = ["TOP.testbench.clk"] + [core + name for name in (
        "ex_valid", "id_ex_pc", "ex_is_mul_instruction", "mul_hazard",
        "top_core_mem_stall", "stall_ex_dataram", "ex_dataram_valid",
        "ex_dataram_rd_addr", "ex_dataram_alu_result", "ex0.mul_start",
        "ex0.mul_inflight", "ex0.mul_done_raw", "ex0.mul_done_latched",
        "ex0.mul_result_valid", "ex0.mul_result_accept", "ex0.ex_can_advance",
        "ex0.mul_3cycle0.state", "ex0.mul_3cycle0.result_reg")]
    setup = [f'[dumpfile] "{wave}"', "[timestart] 330"]
    for name in names:
        width, _, bounds = signals[name]
        setup += ["@28" if width == 1 else "@22", name + bounds]
    wave.with_suffix(".gtkw").write_text("\n".join(setup) + "\n")
    identifier = signals[core + "ex_is_mul_instruction"][1]
    start, spans, now = None, [], 0
    for line in lines:
        if line.startswith("#"):
            now = int(line[1:])
        elif line == "1" + identifier:
            start = now
        elif line == "0" + identifier and start is not None:
            spans.append((start, now))
            start = None
    if len(spans) != 1 or spans[0][1] - spans[0][0] != expected_cycles * 20:
        raise RuntimeError(f"Unexpected EX interval: {spans}")
    return spans[0]


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--no-build", action="store_true")
    args = cli.parse_args()
    os.chdir(RTL)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output = RTL / "test_results"
    output.mkdir(exist_ok=True)
    binary = Path("/tmp/mul_once_verilator/Vtestbench")
    if not args.no_build:
        sources = sorted(str(p) for p in (RTL / "vsrc").rglob("*.v")
                         if p.name != "testbench.v")
        with (output / f"mul_once_{stamp}_build.log").open("w") as log:
            subprocess.run(["verilator", "--binary", "--timing", "--trace",
                            "--trace-depth", "5", "-Wno-fatal", "--top-module",
                            "testbench", "--Mdir", str(binary.parent), "-j", "4",
                            *sources, str(RTL / "tests/mul_once_tb.sv")], check=True,
                           stdout=log, stderr=subprocess.STDOUT,
                           env={**os.environ, "CCACHE_DIR": "/tmp/mul_once_ccache"})
    results = []
    with serialized_images(output):
        with (output / f"mul_once_{stamp}.prepare.log").open("w") as log:
            prepare(RTL / "vsrc/instrom/mul_once.s", toolchain="gnu", output=log)
        for label, after, count in (("mul_once", 0, 0), ("mul_stall_early", 0, 2),
                                    ("mul_stall_completion", 3, 4),
                                    ("mul_stall_raw", 4, 4), ("mul_stall_long", 0, 8)):
            expected = max(5, after + count + 1) if count else 5
            wave = output / f"{label}_{stamp}.vcd"
            log_file = wave.with_suffix(".log")
            with log_file.open("w") as log:
                subprocess.run([str(binary), f"+wave={wave}", f"+expected_ex={expected}",
                                f"+stall_after={after}", f"+stall_cycles={count}"],
                               check=True, stdout=log, stderr=subprocess.STDOUT)
            text = log_file.read_text()
            if "TEST PASSED" not in text:
                raise RuntimeError(f"Test did not pass: {log_file}")
            span = inspect_wave(wave, expected)
            result = f"{label}: EX interval={span}, cycles={expected}; {wave}"
            print(result, flush=True)
            results.append(result)
    (output / f"mul_wave_summary_{stamp}.txt").write_text("\n".join(results) + "\n")


if __name__ == "__main__":
    main()
