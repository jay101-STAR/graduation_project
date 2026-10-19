# Single-MUL waveform

Program: `vsrc/instrom/mul_once.s`. The only MUL is at `0x80000018`:
`mul x7, x5, x6` computes `7 * 9 = 63`. The next instruction copies x7 to
x8, and the program checks the result before setting register tohost x3 to 1.
`tests/mul_once_tb.sv` provides a standalone VCD bench.

## Current N+2 completion handshake

Run from `rtl/`:

```bash
python3 tests/run_mul_once.py
gtkwave test_results/mul_once_20261011_225352.vcd \
        test_results/mul_once_20261011_225352.gtkw
```

The runner rebuilds the current RTL, restores the original memory images, and
checks five cases: no memory wait; an early wait that ends before completion;
wait spanning completion; wait starting during raw completion; and a long wait.
Every case checks a single start/accept, result 63, and the EX duration against
both edge counters and the VCD interval. Each VCD has a matching GTKWave setup.

With no memory wait, EX residence is now 370--470 ns: five complete periods.
At 450 ns, result and `mul_done_raw` are valid and `mul_hazard` deasserts
immediately. At 470 ns, EX/MEM accepts the result and the MUL instruction leaves
EX. `mul_done_latched` stays zero on this direct path. Under memory wait it holds
completion until `mul_result_accept` is sampled; `mul_inflight` prevents restart.

The prior six-period waveform below describes the implementation before this
handshake change.

## Reproduce with Verilator

Run from `rtl/` (preparation intentionally leaves this program in RAM images):

```bash
./run.sh prepare ./vsrc/instrom/mul_once.s --toolchain gnu
mapfile -t mul_sources < <(rg --files vsrc -g '*.v' | rg -v '^vsrc/testbench\.v$')
CCACHE_DIR=/tmp/mul_once_ccache verilator --binary --timing --trace \
  --trace-depth 5 -Wno-fatal --top-module testbench \
  --Mdir /tmp/mul_once_verilator -j 4 \
  "${mul_sources[@]}" tests/mul_once_tb.sv
/tmp/mul_once_verilator/Vtestbench +wave=test_results/mul_once.vcd
gtkwave test_results/mul_once.vcd
```

Alternatively, after preparation, with a working VCS license:

```bash
make simv_build
./simv +bp_pattern_test -l sim.log
make verdi
```

VCS uses the existing testbench and its FSDB output. Its reset timing can
differ from the standalone bench, so identify instruction boundaries using
signals rather than assuming the same absolute times.

## Signals

In the standalone VCD, hierarchy may have a `TOP` prefix. Add:

```text
testbench.clk
testbench.top.u_core.ex_valid
testbench.top.u_core.id_ex_pc
testbench.top.u_core.ex_is_mul_instruction
testbench.top.u_core.mul_hazard
testbench.top.u_core.stall_ex_dataram
testbench.top.u_core.ex_dataram_valid
testbench.top.u_core.ex_dataram_rd_addr
testbench.top.u_core.ex_dataram_alu_result
testbench.top.u_core.ex0.mul_start
testbench.top.u_core.ex0.mul_inflight
testbench.top.u_core.ex0.mul_done_raw
testbench.top.u_core.ex0.mul_done_latched
testbench.top.u_core.ex0.mul_3cycle0.state
testbench.top.u_core.ex0.mul_3cycle0.result_reg
```

Start cursor: rising edge after which `ex_valid=1`, `id_ex_pc=0x80000018`,
and `ex_is_mul_instruction=1`. End cursor: rising edge after which
`ex_dataram_valid=1`, `ex_dataram_rd_addr=7`, and
`ex_dataram_alu_result=63`. Count intervals between these edges.

## Measured result, 2026-10-07

Evidence: `test_results/mul_once_20261007_222846.log` and the matching VCD.
VCS build failed to connect to its license server; Verilator simulation passed.
The bench prints register values 1 ns after each edge, so its printed times
are 1 ns later than the waveform's rising edges.

| Edge | Actual time (ns) | Event |
| --- | ---: | --- |
| E0 | 370 | MUL enters EX |
| E1 | 390 | Input capture, state CYCLE1 |
| E2 | 410 | First stage capture, state CYCLE2 |
| E3 | 430 | Second stage capture, state CYCLE3 |
| E4 | 450 | Product capture, raw completion |
| E5 | 470 | EX captures completion, stall deasserts |
| E6 | 490 | EX/MEM accepts result 63 for x7 |

EX residence is 120 ns / 20 ns = 6 complete periods. `mul_hazard` is high
for 5 periods (370--470 ns). The remaining period lets EX/MEM accept the
result. These are different measurements. Exactly one MUL request was sampled.
