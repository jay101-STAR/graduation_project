# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Response Language

**Always respond in Chinese (简体中文), regardless of whether the user asks in Chinese or English.** Code, identifiers, commands and file paths stay as-is.

## Project Overview

Graduation project: an in-order, single-issue RISC-V CPU (RV32I + RV32M + Zicsr, MRET, ECALL/EBREAK, FENCE.I, precise access faults) in Verilog/SystemVerilog, with a gshare + BTB branch predictor, optional ICache/DCache, and an AXI4 memory/UART subsystem. Active work is under `rtl/`. `AGENTS.md` holds the repo guidelines (style, testing, commits). `rtl/README.md` (Chinese) is the authoritative reference for `run.sh`, and `rtl/docs/*.md` documents each subsystem design.

Do not modify `practise/`, `rtl/vsrc_backup/`, or other historical directories unless asked.

## Build and Test (run from `rtl/`)

The main flow uses Synopsys VCS (`-cpp g++-4.8 -cc gcc-4.8`, `+lint=TFIPC-L`). The Makefile compiles **every** `*.v`/`*.sv` under `vsrc/`, so a new file there is picked up automatically, and a stray file there breaks the build. Python 3.9+, LLVM (`llvm-mc`/`llvm-objcopy`) and `riscv32-unknown-elf-*` are needed for image preparation.

`./run.sh` is a thin wrapper around `tools/run.py`:

```bash
./run.sh build                         # compile only (same as make simv_build)
./run.sh single rv32ui-p-add           # one ISA test
./run.sh isa 'rv32u[im]-p-*'           # ISA batch (includes fence.i unless --skip-fencei)
./run.sh all                           # UART smoke + ISA regression (forces rebuild)
./run.sh uart [--test uart_rx_smoke] [--list]
./run.sh bp | minstret | perf [--tests '...'] | benchmark multiply
./run.sh coremark 1                    # CoreMark; CRC/perf checks done in run.py
./run.sh prepare <elf|.s|.hex> [--toolchain gnu]   # load an image without simulating
make comp                              # prepare bp_tests/bp_tntn.s, build, run
make verdi                             # open testbench.fsdb
python3 -m unittest discover -s tools -p 'test_run.py' -v   # test run.py itself (no VCS)
```

- `--build` / `--no-build` force or skip recompilation. By default it rebuilds when `simv` is missing or stale.
- Test commands overwrite, then restore, `vsrc/instrom/instrom.hex` and `vsrc/dataram/bank{0,1}.{hex,coe,mem}`. **Never run two image-rewriting tests in parallel.** `prepare` keeps the new image.
- Pass condition: the sim prints `TEST PASSED` (ISA: `tohost == 1`; 0 = incomplete, other values = failing case). Evidence goes to `rtl/test_results/` with timestamped summaries, per-test logs, and `failed_tests_*.txt`. `make clean` deletes `test_results/`.
- Testbench plusargs: `+timeout_ns=<N>` (default 400000 ns), `+uart_tx_print`, `+bp_pattern_test`, `+perf_start_pc=/+perf_stop_pc=`, and others (see `vsrc/testbench.v`).

### Verilator-based unit and boundary benches (`rtl/tests/`)

The cache, AXI4 and handshake work is verified with standalone Verilator 5.x benches, because VCS licensing is not always available. The runners build in `/tmp/*_verilator`, take a lock on `test_results/.divider_simulation.lock`, and use a testbench copy with the FSDB calls stripped.

```bash
python3 tests/run_axi4.py --cache-mode 10      # AXI4 unit benches + CPU regression (make test-axi4)
python3 tests/run_cache.py --cache-mode 11     # cache-mode bits = ICache,DCache (00/10/01/11)
python3 tests/run_axi4_units.py --bench axi4_ram_tb --delay 3
```

Other runners: `run_icache.py`, `run_phys_{i,d}cache.py`, `run_access_faults.py`, `run_mem_handshake.py`, `run_{mul,div}_once.py`, `verify_jal_btb.py`. The `*_validation.md` notes next to them record the expected cycle counts.

## Architecture

```text
top.v
├── async_reset                 (async assert / sync release)
├── riscv_core  #(ICACHE_ENABLE=1, DCACHE_ENABLE=0)
│   ├── pipeline: pc, IF1/IF2 regs, if_id_reg, id, id_ex_reg, ex (+mul_3cycle, div),
│   │             ex_dataram_reg, dataram_wb_reg, wb, registerfile, csr, branch_predictor
│   ├── fetch_mem_adapter -> addr_translate_bypass -> mem_attr_decode -> icache_phys_word | cache_word_bypass
│   ├── mem_req_adapter -> lsu -> addr_translate_bypass -> mem_attr_decode -> dcache_phys_word | cache_word_bypass
│   └── mem_burst_arbiter  --> native mem_rd_* / mem_wr_* burst ports (core boundary)
├── axi4_master                 (native bursts -> AXI4, 1 read + 1 write in flight)
└── axi4_subsystem
    ├── axi4_interconnect       (RAM / UART decode, DECERR otherwise)
    ├── axi4_ram_slave          (2 x std_bram_tdp, 64 KiB interleaved banks, tohost observer)
    └── axi4_uart_slave
```

Key cross-file facts:
- **Frontend is two fetch stages (IF1/IF2)** in `riscv_core.v` before `if_id_reg`. Redirects flush IF1, IF2, IF/ID and the stall-return buffer (`frontend_flush`).
- **Control flow:** conditional branches and JALR resolve in EX (`branch_flush`). JAL is predicted in IF through a BTB entry flagged `btb_is_jal`, then checked or redirected in ID (`id_jal_advance` / `id_jal_redirect`). Redirects from older instructions in EX (mispredicts, JALR, traps, MRET, FENCE.I) take priority over the ID JAL redirect. FENCE.I also clears BTB valid bits and invalidates the ICache.
- **Branch predictor:** gshare with `GHR_WIDTH=10` (1024-entry PHT) and a 2-way BTB (`ENTRY_NUM=256`). It trains only when a valid EX instruction is accepted.
- **Stalls:** `stall_*` come from `load_use_hazard`, `mul_hazard`, `div_hazard`, `mem_wait` and `top_core_mem_stall`. `flush_ex_dataram`/`flush_dataram_wb` fire on `mem_trap_fire` (precise access faults from bus errors). MUL/DIV use a valid/accept handshake with `ex_can_advance`: MUL takes 5 EX periods, DIV/REM take N+2 periods (N = iterations, with early-out and fast paths).
- **Memory map** (`mem_attr_decode.v`): RAM `0x8000_0000–0x8000_FFFF`, tohost `0x8000_1000` (its cache line is uncacheable), UART `0x1000_0000–0x1000_000F` (MMIO, single beat), anything else returns DECERR, which becomes an access fault.
- **Native burst protocol:** `len` = beats − 1. Only `0` (bypass) or `15` (64-byte cache line) is produced. Reads use one request handshake plus per-beat responses with `last`. Writes use a per-beat request handshake with `wlast` and a single completion response. Details are in `rtl/docs/core_boundary.md` and `rtl/docs/axi4_bus.md`.
- **Caches:** the ICache is 32 KiB, 4-way, 128 sets, 64 B lines, PLRU (`vsrc/cache/icache.sv`). The DCache is write-back (`dcache.sv`) and does its refill after the dirty writeback finishes. ICache reads can overlap DCache writes.
- Instruction classes are encoded in `vsrc/define.v`: `aluc` (4-bit category) and `alucex` (8-bit operation).

## Conventions and Gotchas

- `include` directives and the Makefile's `verdi` targets use **absolute paths** (`/home/jay/Desktop/graduation_project/...`). Keep them consistent.
- Signals are named `source_dest_signal` with stage prefixes (`id_ex_*`, `ex_reg_rd_wen`). Use two-space indent, explicit widths and named port connections. Comments mix Chinese and English.
- Diagrams in docs and responses use plain-text boxes in ```text blocks, not Mermaid (from AGENTS.md).
- Validation order for RTL changes: focused test, then the subsystem suite, then broad regression. Performance changes need CoreMark plus mcycle/minstret/CPI comparisons. Commit messages follow `<scope>: <action>` (e.g. `core/ex: fix BLTU compare path`).
- `rtl/todolist.txt` tracks pending work (e.g. moving the adapters into the core and adding a refill buffer).
