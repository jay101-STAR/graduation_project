#!/usr/bin/env python3
"""Legacy array-interface tests for icache.sv; current controller tests use run_phys_icache.py.

The default suite includes two additional contract probes: whether fills update
PLRU recency, and whether a fill of an already resident tag replaces its data.
Probe failures are real observations, not expected-success test outcomes; the
report distinguishes them from basic tests because the input contract is not
documented by the module. Any failed case makes the command return nonzero.
"""
import argparse
from datetime import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import subprocess
import sys

RTL = Path(__file__).resolve().parents[1]
CASES = {
    "reset": ("basic", "reset invalidates all 512 lines; refill after reset"),
    "line_words": ("basic", "all 16 words; line boundaries; highest and lowest addresses"),
    "all_sets_ways": ("basic", "all 128 sets x 4 ways x 16 words against data oracle"),
    "address_bits": ("basic", "each index/tag address bit independently distinguishes lines"),
    "enables_timing": ("basic", "read/write enables and registered read timing"),
    "four_way_capacity": ("basic", "four resident lines; fifth evicts exactly one"),
    "plru_read_history": ("basic", "64 histories of three hits; expected tree-PLRU victim"),
    "set_isolation": ("basic", "per-set data and PLRU isolation"),
    "read_fill_miss": ("basic", "simultaneous read/fill miss sees old state, then new data"),
    "random_fits": ("basic", "10000 randomized operations plus exhaustive final data check"),
    "refill_recency": ("contract", "a newly installed line remains recent across another fill"),
    "duplicate_fill": ("contract", "refilling a resident tag must not return a stale duplicate"),
}


def sha256(contents):
    return hashlib.sha256(contents).hexdigest()


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--case", action="append", choices=CASES, help="Repeat to select cases; default all")
    cli.add_argument("--basic", action="store_true", help="Run basic cases only, excluding contract probes")
    cli.add_argument("--seed", type=int, action="append", help="Random case seeds; default 1,493,65535")
    cli.add_argument("--wave", action="store_true", help="Dump all selected cases (small probes always dump)")
    cli.add_argument("--build-dir", type=Path, help="Default: a unique directory under /tmp")
    cli.add_argument("--dut", type=Path, default=RTL / "vsrc/cache/icache.sv",
                     help="DUT source; alternate copies are for explicit cross-checks")
    cli.add_argument("--unroll-count", type=int, default=256,
                     help="Verilator reset-loop unroll limit; 256 avoids this installed 5.027 build's partial-NBA issue")
    args = cli.parse_args()
    if args.basic and args.case:
        cli.error("select --basic or --case, not both")
    seeds = args.seed or [1, 493, 65535]
    if any(seed <= 0 or seed > 0xffffffff for seed in seeds):
        cli.error("seeds must be 1..4294967295")
    if args.unroll_count <= 0:
        cli.error("unroll-count must be positive")
    selected = args.case or [name for name, (group, _) in CASES.items() if not args.basic or group == "basic"]
    os.chdir(RTL)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    results = RTL / "test_results"
    results.mkdir(exist_ok=True)
    prefix = results / f"icache_unit_{stamp}"
    build = args.build_dir.resolve() if args.build_dir else Path(f"/tmp/icache_unit_{stamp}")
    build.mkdir(parents=True, exist_ok=True)
    # A failing assertion should not leave a large core file in the workspace.
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    source = args.dut.resolve()
    bench = RTL / "tests/icache_unit_tb.sv"
    source_bytes, bench_bytes = source.read_bytes(), bench.read_bytes()
    (build / "icache.sv").write_bytes(source_bytes)
    (build / "icache_unit_tb.sv").write_bytes(bench_bytes)
    snapshot = prefix.with_suffix(".dut.sv")
    snapshot.write_bytes(source_bytes)
    evidence = {"source": str(source), "source_sha256": sha256(source_bytes), "unroll_count": args.unroll_count,
                "bench_sha256": sha256(bench_bytes), "snapshot": str(snapshot),
                "interface": "32KiB, 4 ways, 128 sets, 64B line, 32-bit address, whole-line fill",
                "simulator": subprocess.run(["verilator", "--version"], capture_output=True, text=True,
                                            check=True).stdout.strip(), "cases": []}
    lint_log = prefix.with_suffix(".lint.log")
    with lint_log.open("w") as output:
        status = subprocess.run(["verilator", "--lint-only", "--timing", "-Wall", "-Wno-fatal",
                                 "--unroll-count", str(args.unroll_count),
                                 "--top-module", "icache", str(build / "icache.sv")],
                                stdout=output, stderr=subprocess.STDOUT, timeout=60)
    evidence["lint"] = {"exit_code": status.returncode, "log": str(lint_log),
                        "warnings": len(re.findall(r"%Warning", lint_log.read_text()))}
    if status.returncode:
        raise RuntimeError(f"DUT lint failed; see {lint_log}")
    build_log = prefix.with_suffix(".build.log")
    with build_log.open("w") as output:
        subprocess.run(["verilator", "--binary", "--timing", "--trace", "--trace-depth", "2",
                        "--unroll-count", str(args.unroll_count),
                        "--timescale", "1ns/1ns", "-Wno-fatal", "--top-module", "icache_unit_tb",
                        "--Mdir", str(build / "obj"), "-j", "4",
                        str(build / "icache.sv"), str(build / "icache_unit_tb.sv")],
                       check=True, stdout=output, stderr=subprocess.STDOUT, timeout=180,
                       env={**os.environ, "CCACHE_DIR": "/tmp/p1_ccache"})
    evidence["build_log"] = str(build_log)
    print(f"DUT sha256: {evidence['source_sha256']}; lint warnings={evidence['lint']['warnings']}", flush=True)
    for name in selected:
        group, description = CASES[name]
        for seed in seeds if name == "random_fits" else [seeds[0]]:
            log = Path(f"{prefix}_{name}_{seed}.log")
            wave = Path(f"{prefix}_{name}_{seed}.vcd") if args.wave or group == "contract" or name == "line_words" else None
            command = [str(build / "obj/Vicache_unit_tb"), f"+case={name}", f"+seed={seed}"]
            if wave:
                command.append(f"+wave={wave}")
            with log.open("w") as output:
                try:
                    status = subprocess.run(command, stdout=output, stderr=subprocess.STDOUT, timeout=30)
                    passed = status.returncode == 0 and f"[ICACHE-UNIT] PASS case={name}" in log.read_text()
                except subprocess.TimeoutExpired:
                    passed = False
            contents = log.read_text()
            row = {"case": name, "group": group, "description": description, "seed": seed,
                   "status": "PASS" if passed else "FAIL", "log": str(log),
                   "wave": str(wave) if wave else None}
            failure = next((line for line in contents.splitlines() if "[ICACHE-FAIL]" in line), None)
            if failure:
                row["failure"] = failure
            evidence["cases"].append(row)
            print(f"{group}/{name} seed={seed}: {row['status']}; {log}", flush=True)
            if failure:
                print(failure, flush=True)
    evidence["source_unchanged"] = source.read_bytes() == source_bytes
    manifest = prefix.with_suffix(".json")
    manifest.write_text(json.dumps(evidence, indent=2) + "\n")
    lines = ["# ICache 独立测试结果", "", f"日期：{stamp}。仿真器：{evidence['simulator']}。",
             f"编译选项：`--unroll-count {args.unroll_count}`。",
             f"测试源：`{source}`；SHA256：`{evidence['source_sha256']}`。",
             f"测试期间源文件保持不变：{evidence['source_unchanged']}。未修改 DUT 或连接 CPU。", "",
             "实际接口：32 KiB、四路、128 组、64 B 行、32 位地址、整行写入、同步读。", "",
             "| 用例 | 类型 | seed | 结果 | 日志 |", "| --- | --- | ---: | --- | --- |"]
    for row in evidence["cases"]:
        lines.append(f"| {row['case']} | {row['group']} | {row['seed']} | {row['status']} | [{Path(row['log']).name}]({Path(row['log']).name}) |")
    lines += ["", "basic 只对现有存储/查找接口验收。contract 是尚需明确输入约定/替换语义的额外探测，失败不计为通过。", ""]
    for row in evidence["cases"]:
        if row.get("failure"):
            lines += [f"- `{row['case']}`：`{row['failure']}`"]
    lines += ["", "现有接口没有 req/rsp 握手、逐字补行、后端错误、地址属性旁路和维护端口，这些功能未测试。",
              "这份结果不表示完成整个 C1 或具备直接替换 C0 旁路模块的接口。", "",
              f"DUT lint 警告数：{evidence['lint']['warnings']}。完整机器可读结果：[{manifest.name}]({manifest.name})。", ""]
    report = prefix.with_suffix(".md")
    report.write_text("\n".join(lines))
    failed = sum(row["status"] != "PASS" for row in evidence["cases"])
    print(f"Result: {len(evidence['cases']) - failed}/{len(evidence['cases'])} PASS; {failed} FAIL", flush=True)
    print(f"Report: {report}\nManifest: {manifest}", flush=True)
    return int(failed != 0 or not evidence["source_unchanged"])


if __name__ == "__main__":
    sys.exit(main())
