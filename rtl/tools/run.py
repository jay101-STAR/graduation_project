#!/usr/bin/env python3
"""Unified CPU test runner. Invoke from any directory through rtl/run.sh."""

import argparse
from contextlib import contextmanager
from datetime import datetime
import fnmatch
import os
from pathlib import Path
import re
import shlex
import signal
import subprocess
import sys
import tempfile


RTL = Path(__file__).resolve().parents[1]
PROJECT = RTL.parent
INST = RTL / "vsrc/instrom"
DATA = RTL / "vsrc/dataram"
MEM_TOOL = DATA / "mem_image_tool.py"
ISA = PROJECT / "verification/riscv-tests/isa"
BENCH = PROJECT / "verification/riscv-tests/benchmarks/rv32im_build"
UART = {
    "uart_tx_smoke": ("uart_tx_smoke_test.s", "+uart_tx_smoke"),
    "uart_tx_back_to_back": ("uart_tx_back_to_back_test.s", "+uart_tx_smoke"),
    "uart_loopback_echo": ("uart_loopback_echo_test.s", "+uart_loopback_smoke"),
    "uart_rx_smoke": ("uart_rx_smoke_test.s", "+uart_rx_smoke"),
    "uart_rx_double": ("uart_rx_double_read_test.s", "+uart_rx_smoke"),
    "uart_rx_overrun": ("uart_rx_overrun_test.s", "+uart_rx_overrun_smoke"),
}
DEFAULT_PATTERN = "rv32u[im]-p-*"
DEFAULT_PERF = ["rv32ui-p-add", "rv32ui-p-beq", "rv32ui-p-lw",
                "rv32ui-p-sw", "rv32um-p-mul", "rv32um-p-div"]
IMAGES = [INST / "instrom.hex"] + [DATA / f"bank{bank}.{suffix}"
                                  for bank in (0, 1) for suffix in ("hex", "coe", "mem")]


def command(args, **kwargs):
    """Use argv throughout, including user paths and simulator arguments."""
    return subprocess.run([str(arg) for arg in args], check=True, cwd=RTL, **kwargs)


def memory_command(*args, output=None):
    command([sys.executable, MEM_TOOL, *args], stdout=output,
            stderr=subprocess.STDOUT if output else None)


@contextmanager
def restore_images(keep_on_success=False):
    # Include COE/MEM and originally absent files; restore on failures/signals.
    saved = {path: path.read_bytes() if path.exists() else None for path in IMAGES}
    completed = False
    try:
        yield
        completed = True
    finally:
        if not (completed and keep_on_success):
            for path, content in saved.items():
                if content is None:
                    path.unlink(missing_ok=True)
                else:
                    path.write_bytes(content)


def prepare(source, toolchain="llvm", output=None):
    source = Path(source).resolve()
    if not source.is_file():
        raise ValueError(f"input not found: {source}")
    elf = None
    if source.suffix == ".s":
        helper = "llvm.sh" if toolchain == "llvm" else "asm2hex.sh"
        command(["bash", INST / helper, source], stdout=output,
                stderr=subprocess.STDOUT if output else None)
        source = source.with_suffix(".hex")
    if source.suffix == ".hex":
        content = source.read_bytes()
    else:
        elf = source
        # A private binary avoids collisions and cleans up failed conversion.
        with tempfile.TemporaryDirectory(prefix="riscv-image-") as temp:
            binary = Path(temp) / "image.bin"
            command(["riscv32-unknown-elf-objcopy", "-O", "binary", source, binary],
                    stdout=output, stderr=subprocess.STDOUT if output else None)
            raw = binary.read_bytes()
        if not raw:
            raise ValueError(f"ELF image is empty: {source}")
        # Data sections may end with a byte/halfword: zero-pad the final word.
        raw += bytes((-len(raw)) % 4)
        content = "".join(f"{int.from_bytes(raw[i:i + 4], 'little'):08x}\n"
                          for i in range(0, len(raw), 4)).encode()
    (INST / "instrom.hex").write_bytes(content)
    memory_command("init-instrom", "--instrom", INST / "instrom.hex", "--out-dir", DATA,
                   output=output)
    if elf is not None:
        memory_command("overlay-data", "--elf", elf, "--out-dir", DATA, output=output)
    memory_command("emit", "--dir", DATA, output=output)


def build(args, log):
    sim = RTL / "simv"
    if args.no_build:
        if not os.access(sim, os.X_OK):
            raise ValueError("simv is missing/not executable; run ./run.sh build")
        return
    newer = not sim.exists() or any(p.stat().st_mtime_ns > sim.stat().st_mtime_ns
                                   for p in (RTL / "vsrc").rglob("*")
                                   if p.suffix in (".v", ".sv") and p.is_file())
    if args.build or newer or args.mode == "all":
        print(f"Building simv; log: {log}", flush=True)
        with log.open("w") as output:
            command(["make", "simv_build"], stdout=output, stderr=subprocess.STDOUT)
    if not os.access(sim, os.X_OK):
        raise ValueError("simv is missing/not executable after build")


def fields(text, tag):
    lines = re.findall(r"\[" + re.escape(tag) + r"\]([^\n]*)", text)
    return dict(re.findall(r"([a-z_]+)=([0-9]+(?:\.[0-9]+)?)", lines[-1])) if lines else {}


def simulate(log, plusargs, timeout):
    # Terminate the entire simulator process group before restoring its images.
    with log.open("w") as output:
        proc = subprocess.Popen([str(RTL / "simv"), *plusargs, "-l", "sim.log"],
                                cwd=RTL, stdout=output, stderr=subprocess.STDOUT,
                                start_new_session=True)
        try:
            rc = proc.wait(timeout=timeout or None)
        except (subprocess.TimeoutExpired, KeyboardInterrupt) as error:
            try:
                os.killpg(proc.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait()
            if isinstance(error, KeyboardInterrupt):
                raise
            return "TIMEOUT", log.read_text(errors="replace")
    text = log.read_text(errors="replace")
    if re.search(r"Failed to obtain license|Cannot connect to the license server", text, re.I):
        return "LICENSE", text
    if rc:
        return "SIM_ERROR", text
    if re.search(r"TEST FAILED|TIMEOUT", text):
        return "FAIL", text
    return ("PASS" if "TEST PASSED" in text else "UNKNOWN"), text


def isa_tests(pattern):
    # Match basenames like the old find -name interface; do not interpret shell input.
    matches = sorted(p for p in ISA.rglob("*") if p.is_file()
                     and p.suffix != ".dump" and fnmatch.fnmatchcase(p.name, pattern))
    if not matches:
        raise ValueError(f"no ISA tests match: {pattern}")
    return matches


def selected_tests(args):
    """Each case: suite, display name, source, simulator argv, wall timeout."""
    tests = []
    if args.mode in ("all", "uart"):
        names = [args.test] if args.mode == "uart" and args.test else list(UART)
        for name in names:
            asm, plusarg = UART[name]
            tests.append(("uart", name, INST / asm, [plusarg, "+bp_pattern_test"], 30))
    if args.mode in ("all", "isa", "single", "perf"):
        if args.mode == "perf":
            names = args.tests.split() if args.tests else DEFAULT_PERF
            if not names:
                raise ValueError("test list is empty")
            paths = [isa_tests(name)[0] for name in names]
        else:
            paths = isa_tests(args.name if args.mode == "single" else args.pattern)
            if args.mode == "single" and (len(paths) != 1 or paths[0].name != args.name):
                raise ValueError("single requires one exact ISA test name; use isa for patterns")
        skip = re.compile(os.environ["SKIP_TEST_REGEX"]) if os.environ.get("SKIP_TEST_REGEX") else None
        for path in paths:
            filtered = (getattr(args, "skip_fencei", False) and path.name == "rv32ui-p-fence_i")
            filtered = filtered or (skip and skip.search(path.name))
            tests.append(("perf" if args.mode == "perf" else "isa", path.name, path,
                          None if filtered else [], 120 if args.mode == "perf" else 10))
    if args.mode in ("bp", "minstret"):
        folder = INST / ("bp_tests" if args.mode == "bp" else "minstret_tests")
        paths = sorted(folder.glob("*.s"))
        if not paths:
            raise ValueError(f"no assembly tests under {folder}")
        ns = positive(os.environ.get("BP_TIMEOUT_NS", "10000000"))
        wall = positive(os.environ.get("BP_WALL_TIMEOUT_S", "120"))
        for path in paths:
            tests.append((args.mode, path.stem, path,
                          ["+bp_pattern_test", f"+timeout_ns={ns}"] if args.mode == "bp" else [],
                          wall if args.mode == "bp" else 10))
    if args.mode == "benchmark":
        if Path(args.name).name != args.name:
            raise ValueError("benchmark name must be a basename")
        tests.append(("benchmark", args.name, BENCH / "output" / f"{args.name}.hex", [], 60))
    return tests


def run_cases(args, tests, results, stamp, summary):
    rows = []
    total_cycles = total_instructions = branches = misses = target_misses = 0
    cpi_sum = 0.0
    perf_samples = bp_samples = 0
    for index, (suite, name, source, plusargs, wall) in enumerate(tests, 1):
        log = results / f"{stamp}_{suite}_{name}.log"
        perf, bp = {}, {}
        if plusargs is None:
            status = "SKIP"
            log.write_text("Excluded by --skip-fencei or SKIP_TEST_REGEX\n")
        else:
            try:
                # Keep assembly/conversion diagnostics with the case evidence.
                with log.open("w") as output:
                    prepare(source, output=output)
                status, text = simulate(log.with_suffix(".sim.log"), plusargs, wall)
                perf, bp = fields(text, "PERF"), fields(text, "BP")
                if suite == "bp" and status == "PASS" and not valid_bp(bp):
                    status = "BP_PARSE_FAIL"
            except (ValueError, OSError, subprocess.CalledProcessError) as error:
                status = "PREPARE_FAIL"
                with log.open("a") as output:
                    output.write(f"\n{error}\n")
            if status == "PASS":
                if all(key in perf for key in ("mcycle", "minstret", "cpi")):
                    total_cycles += int(perf["mcycle"])
                    total_instructions += int(perf["minstret"])
                    cpi_sum += float(perf["cpi"])
                    perf_samples += 1
                if valid_bp(bp):
                    branches += int(bp["branches"])
                    misses += int(bp["mispredict"])
                    target_misses += int(bp["target_miss"])
                    bp_samples += 1
        row = {"suite": suite, "name": name, "result": status, "perf": perf, "bp": bp}
        rows.append(row)
        message = f"[{index:02}/{len(tests):02}] {suite}/{name}: {status}"
        if perf:
            message += " " + " ".join(f"{k}={v}" for k, v in perf.items())
        if bp:
            message += " " + " ".join(f"{k}={v}" for k, v in bp.items())
        print(message, flush=True)
        with summary.open("a") as output:
            output.write(message + "\n")
    failed = [row for row in rows if row["result"] not in ("PASS", "SKIP")]
    lines = [f"Total: {len(rows)}", f"Pass: {sum(r['result'] == 'PASS' for r in rows)}",
             f"Fail: {len(failed)}", f"Skip: {sum(r['result'] == 'SKIP' for r in rows)}",
             f"Perf samples: {perf_samples}", f"Total mcycle: {total_cycles}",
             f"Total minstret: {total_instructions}",
             f"Average CPI: {cpi_sum / perf_samples:.4f}" if perf_samples else "Average CPI: N/A",
             f"Weighted CPI: {total_cycles / total_instructions:.4f}" if total_instructions else "Weighted CPI: N/A",
             f"BP samples: {bp_samples}", f"Total branches: {branches}",
             f"Total mispredict: {misses}", f"Total target miss: {target_misses}"]
    if branches:
        lines += [f"Weighted accuracy: {(branches - misses) * 100 / branches:.2f}%",
                  f"Direction miss rate: {(misses - target_misses) * 100 / branches:.2f}%",
                  f"Target miss rate: {target_misses * 100 / branches:.2f}%"]
    report = "\n".join(lines) + "\n"
    with summary.open("a") as output:
        output.write(report)
    if failed:
        (results / f"failed_tests_{stamp}.txt").write_text(
            "".join(f"{row['suite']}/{row['name']}: {row['result']}\n" for row in failed))
    print(report + f"Summary: {summary}", flush=True)
    return int(bool(failed))


def valid_bp(bp):
    return all(bp.get(key, "").isdigit() for key in ("branches", "mispredict", "target_miss"))


def positive(value):
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be a positive integer")
    return number


def validate_coremark(log, source):
    def field(pattern, name):
        match = re.search(pattern, log)
        if not match:
            raise ValueError(f"missing {name}")
        return match

    if "TEST PASSED" not in log or re.search(r"TEST FAILED|TIMEOUT", log):
        raise ValueError("simulation did not complete successfully")
    seed = int(field(r"seedcrc\s*:\s*0x([0-9a-fA-F]+)", "seed CRC")[1], 16)
    seeds = [0x8a02, 0x7b05, 0x4eaf, 0xe9f5, 0x18f2]
    if seed not in seeds:
        raise ValueError(f"unknown seed CRC: {seed:#06x}")
    index = seeds.index(seed)
    for algorithm in ("list", "matrix", "state"):
        table = re.search(rf"{algorithm}_known_crc\[\]\s*=\s*\{{([^}}]+)\}}", source)
        if not table:
            raise ValueError(f"missing reference CRC table: {algorithm}")
        references = re.findall(r"0x[0-9a-fA-F]+", table[1])
        if index >= len(references):
            raise ValueError(f"incomplete reference CRC table: {algorithm}")
        expected = int(references[index], 16)
        actual = int(field(rf"\[0\]crc{algorithm}\s*:\s*0x([0-9a-fA-F]+)",
                           f"{algorithm} CRC")[1], 16)
        if actual != expected:
            raise ValueError(f"{algorithm} CRC {actual:#06x}, expected {expected:#06x}")

    # A short simulation is useful for optimization but is not an official score.
    duration_error = "ERROR! Must execute for at least 10 secs for a valid result!"
    other_errors = [line for line in log.splitlines()
                    if "ERROR!" in line and duration_error not in line]
    if other_errors or "Cannot validate operation" in log:
        raise ValueError("CoreMark reported errors beyond the short-run duration")
    if "Errors detected" in log and duration_error not in log:
        raise ValueError("CoreMark reported unexplained errors")
    region = field(r"\[PERF-REGION\] mcycle=(\d+) minstret=(\d+)", "region counters")
    cycles, instructions = map(int, region.groups())
    if not cycles or not instructions:
        raise ValueError("empty measurement window")
    buckets = field(r"\[STALL-REGION\] mem=(\d+) mul=(\d+) div=(\d+) "
                    r"load_use=(\d+) unstalled=(\d+) redirects=(\d+)", "stall counters")
    if sum(map(int, buckets.groups()[:5])) != cycles:
        raise ValueError("stall cycle buckets do not sum to region cycles")
    messages = ["[CoreMark-check] CRCs verified; measurement counters consistent"]
    if duration_error in log:
        messages.append("[CoreMark-check] Short-run comparison only; 10-second score requirement unmet")
    return messages



def coremark(args, results, stamp, summary):
    core = PROJECT / "verification/coremark"
    port = core / "riscv_port"
    iterations = args.iterations if args.iterations is not None else positive(os.environ.get("ITERATIONS", "1"))
    ns = int(os.environ.get("TB_TIMEOUT_NS", "100000000000"))
    wall = int(os.environ.get("SIM_TIMEOUT", "0"))
    hz = positive(os.environ.get("CORE_FREQ_HZ", "50000000"))
    if ns < 0 or wall < 0 or os.environ.get("UART_PRINT", "1") != "1":
        raise ValueError("CoreMark requires UART_PRINT=1 and nonnegative timeouts")
    # Build artifacts live under rtl; do not overwrite the verification ELF.
    elf = results / f"coremark_{stamp}.elf"
    sources = [core / name for name in ("core_list_join.c", "core_main.c", "core_matrix.c",
                                       "core_state.c", "core_util.c")]
    sources += [port / "core_portme.c", port / "ee_printf.c",
                BENCH / "syscalls_rv32im.c", BENCH / "crt_rv32im.S"]
    with (results / f"coremark_{stamp}_build.log").open("w") as output:
        command(["riscv32-unknown-elf-gcc", "-march=rv32im_zicsr", "-mabi=ilp32",
                 "-O2", "-ffreestanding", "-nostdlib", f"-DITERATIONS={iterations}",
                 '-DFLAGS_STR="-O2 -ffreestanding -nostdlib"', f"-I{core}", f"-I{port}",
                 *sources, "-T", BENCH / "link_rv32im.ld", "-o", elf],
                stdout=output, stderr=subprocess.STDOUT)
    prepare(elf)
    symbols = command(["riscv32-unknown-elf-nm", elf], capture_output=True, text=True).stdout
    addresses = {}
    for line in symbols.splitlines():
        parts = line.split()
        if len(parts) == 3 and parts[2] in ("start_time", "stop_time"):
            addresses[parts[2]] = parts[0]
    if len(addresses) != 2:
        raise ValueError("CoreMark start_time/stop_time symbols missing")
    extra = shlex.split(os.environ.get("SIM_ARGS", ""))
    plusargs = [f"+perf_start_pc={addresses['start_time']}",
                f"+perf_stop_pc={addresses['stop_time']}", *extra]
    if ns and not any(arg.startswith("+timeout_ns=") for arg in extra):
        plusargs.append(f"+timeout_ns={ns}")
    if "+uart_tx_print" not in extra:
        plusargs.append("+uart_tx_print")
    log = results / f"coremark_{stamp}.log"
    status, text = simulate(log, plusargs, wall)
    validation = []
    if status == "PASS":
        try:
            validation = validate_coremark(text, (core / "core_main.c").read_text())
        except (ValueError, OSError) as error:
            status = "CRC_FAIL"
            validation = [f"[CoreMark-check] FAIL: {error}"]
    lines = [f"CoreMark iterations={iterations}: {status}", *validation]
    for line in text.splitlines():
        if re.search(r"\[PERF|\[STALL-REGION\]|\[BP\]|CoreMark|Iterations|Total ticks|Total time", line):
            lines.append(line)
    cycles = fields(text, "PERF-REGION").get("mcycle", "0")
    if status == "PASS" and int(cycles) > 0:
        lines += [f"Short-run region Iterations/Sec: {iterations * hz / int(cycles):.3f} (@{hz} Hz)",
                  f"Short-run region iterations/MHz: {iterations * 1000000 / int(cycles):.6f}"]
    report = "\n".join(lines) + f"\nEvidence: {log}\n"
    with summary.open("a") as output:
        output.write(report)
    print(report, flush=True)
    return int(status != "PASS")


def parser():
    cli = argparse.ArgumentParser(prog="./run.sh", description=__doc__)
    sub = cli.add_subparsers(dest="mode", required=True)
    for mode, help_text in [("all", "UART + ISA regression"), ("isa", "ISA pattern regression"),
                            ("single", "one ISA test"), ("uart", "UART regression"),
                            ("bp", "branch predictor patterns"), ("perf", "performance baseline"),
                            ("minstret", "CSR retirement-counter assembly tests"),
                            ("benchmark", "RV32IM benchmark"), ("coremark", "CoreMark with CRC validation")]:
        item = sub.add_parser(mode, help=help_text)
        group = item.add_mutually_exclusive_group()
        group.add_argument("--build", action="store_true", help="force simv rebuild")
        group.add_argument("--no-build", action="store_true", help="reuse existing simv")
        if mode in ("all", "isa"):
            item.add_argument("pattern", nargs="?", default=DEFAULT_PATTERN)
            skip = item.add_mutually_exclusive_group()
            skip.add_argument("--skip-fencei", action="store_true")
            skip.add_argument("--no-skip-fencei", action="store_false", dest="skip_fencei")
            item.set_defaults(skip_fencei=False)
        if mode in ("single", "benchmark"):
            item.add_argument("name")
        if mode == "uart":
            item.add_argument("--test", choices=list(UART))
            item.add_argument("--list", action="store_true")
        if mode == "perf":
            item.add_argument("--tests", help="quoted space-separated test names")
        if mode == "coremark":
            item.add_argument("iterations", nargs="?", type=positive)
    item = sub.add_parser("prepare", help="prepare ELF/.s/.hex images without simulation; keep images")
    item.add_argument("source", type=Path)
    item.add_argument("--toolchain", choices=("llvm", "gnu"), default="llvm")
    item = sub.add_parser("check-coremark", help="validate an existing CoreMark log without simulation")
    item.add_argument("log", type=Path)
    item.add_argument("--source", type=Path, default=PROJECT / "verification/coremark/core_main.c")
    sub.add_parser("build", help="compile RTL without running tests")
    return cli


def interrupted(_signum, _frame):
    raise KeyboardInterrupt


def main():
    args = parser().parse_args()
    signal.signal(signal.SIGTERM, interrupted)
    if args.mode == "check-coremark":
        print("\n".join(validate_coremark(args.log.read_text(), args.source.read_text())))
        return 0
    if args.mode == "uart" and args.list:
        print("\n".join(UART))
        return 0
    if args.mode == "prepare":
        with restore_images(keep_on_success=True):
            prepare(args.source, args.toolchain)
        return 0
    results = RTL / "test_results"
    results.mkdir(exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    if args.mode == "build":
        log = results / f"simv_build_{stamp}.log"
        print(f"Build log: {log}", flush=True)
        with log.open("w") as output:
            command(["make", "simv_build"], stdout=output, stderr=subprocess.STDOUT)
        return 0
    tests = [] if args.mode == "coremark" else selected_tests(args)
    if args.mode == "coremark" and os.environ.get("SKIP_BUILD") == "1" and not args.build:
        args.no_build = True
    summary = results / f"{args.mode}_summary_{stamp}.txt"
    summary.write_text(f"Mode: {args.mode}\nStart: {datetime.now().isoformat()}\n"
                       f"Arguments: {sys.argv[1:]!r}\nSKIP_TEST_REGEX: {os.environ.get('SKIP_TEST_REGEX', '')}\n")
    with restore_images():
        build(args, results / f"simv_build_{stamp}.log")
        if args.mode == "coremark":
            return coremark(args, results, stamp, summary)
        return run_cases(args, tests, results, stamp, summary)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.CalledProcessError, argparse.ArgumentTypeError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("Interrupted; memory images restored for test commands.", file=sys.stderr)
        sys.exit(130)
