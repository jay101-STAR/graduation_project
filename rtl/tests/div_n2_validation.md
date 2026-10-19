# DIV/REM N+2 handshake: 2026-10-11

## Changes

`vsrc/core/ex.v` now exposes divider completion using
`div_result_valid = div_done_latched || (div_inflight && div_done_raw)`.
The quotient/remainder registers and raw done become valid on the same edge,
so the pipeline can release its divider hazard during the following period.
`div_result_accept` requires both a valid division result and `ex_can_advance`.
Inflight and pending completion clear only when EX/MEM accepts the result, or
when EX no longer contains a division instruction. If memory blocks acceptance,
EX latches completion and retains inflight to prevent another start.

`vsrc/core/div.v` returns directly from WORK to IDLE on the edge after raw done,
clears busy/done, and retains its quotient/remainder registers. The former DONE
state is removed. This makes the divider ready for a following DIV/REM without
an extra idle wait. A result blocked in EX remains protected by inflight, even
after the divider itself returns to IDLE.

The previously validated final-iteration `dividend_next` capture, sign recovery,
prefix skipping, and fast paths are unchanged by this change. The existing MUL
N+2 handshake and the `ex_can_advance` connection in `riscv_core.v` are reused.

Without another pipeline stall, ordinary DIV/REM now occupies
`1 input-capture + N iterations + 1 EX/MEM transfer = N+2` complete EX periods.
The removed period was EX capturing raw done into its completion register.

| Case | Iterations N | Before EX periods | After EX periods | After hazard periods |
| --- | ---: | ---: | ---: | ---: |
| Signed 100 / 3 | 7 | 10 | 9 | 8 |
| Unsigned 0xffffffff / 3 | 31 | 34 | 33 | 32 |
| Signed 100 / 3, testbench disables prefix skip | 32 | 35 | 34 | 33 |
| Signed 100 / 1, fast path | fast path | 4 | 3 | 2 |

## Functional validation

All simulations used Verilator 5.027. The attempted VCS build could not connect
to its license server; the existing `simv` was not rebuilt and must not be
assumed to contain this change. Full-system regression uses a temporary copy
of the repository testbench with only unsupported FSDB dumping removed.
Memory-image preparation and simulations are serialized, and the previous
images are restored after each run.

| Check | Result |
| --- | --- |
| Independent divider reference | 2339/2339 PASS: 338 signed/unsigned edge combinations, 2000 deterministic random cases, one post-reset case |
| Corner cases | PASS: divide by zero, INT_MIN/-1 overflow, sign combinations, zero, magnitude-one divisor, unsigned power-of-two divisor, ordinary long division |
| Divider control | PASS: result stability, busy/done clear on the first edge after completion, consecutive requests, reset during an operation |
| Three single-division programs | PASS: expected quotient/remainder and EX latency, exactly one start/acceptance, tohost=1 |
| Forced full iteration | PASS: 32 iteration edges, EX 34 periods, hazard 33 periods, quotient 33, remainder 1 |
| Five memory-stall schedules | PASS: early, across completion, during raw done, long, and fast-path waits; pending data/completion retained without restart |
| div_handshake assembly | PASS: consecutive DIV/REM/DIVU/REMU, direct dependencies, same destination, x0, exceptional/fast paths, MUL/DIV transitions, load/store dependencies |
| Existing mul_handshake assembly | PASS: consecutive/dependent multiplication and mixed MUL/DIV/REM |
| Focused rv32um-p-div | 1/1 PASS |
| RV32M subsystem | 8/8 PASS |
| Broad ISA/UART regression | 50 ISA + 6 UART = 56/56 PASS; zero failures and zero exclusions, including FENCE.I |
| CoreMark | Before/after CRCs and measurement consistency PASS |

Main evidence, all under `test_results/`:

- `div_n2_20261011_230833_unit.log`
- `div_n2_20261011_230833_baseline_run.log`
- `div_n2_20261011_230833_after_run.log`
- `div_n2_20261011_230833_vcs_build.log`
- `div_handshake_20261011_231304.log`
- `mul_handshake_20261011_231304.log`
- `isa_summary_20261011_231319_450817.txt`
- `all_summary_20261011_231322_814888.txt`
- `div_wave_summary_20261011_230937.txt` (full 32 iterations)
- `div_wave_summary_20261011_231304.txt` (normal/fast/long and stalls)

The saved baseline RTL is `div_n2_20261011_230833_{div,ex,riscv_core}_before.v`
under `test_results/`. It includes the earlier final-iteration merge and MUL
N+2 change, but retains the DIV N+3 completion handshake.

## Performance comparison

One CoreMark iteration, identical compiler flags, measured region, and simulator.
This is a short-run comparison, not an official CoreMark score.

| Metric | Before | After |
| --- | ---: | ---: |
| Region mcycle | 394962 | 394962 |
| Region minstret | 287265 | 287265 |
| Region CPI | 1.3749 | 1.3749 |
| Region division stall cycles | 0 | 0 |
| Whole-program mcycle | 2335602 | 2335601 |
| Whole-program minstret | 307901 | 307901 |
| Whole-program CPI | 7.5856 | 7.5856 |

This CoreMark region executes no division, so it shows no region improvement.
The single-division waveform checks above directly verify the one-period saving.
CoreMark evidence: `coremark_20261011_231038_966689.log` (before) and
`coremark_20261011_231346_441482.log` (after).

No synthesis timing analysis was performed. Arithmetic is unchanged, but the
raw-completion path to pipeline enables still needs hardware timing validation.

## Waveform and reproduction

From `rtl/`, open the measured full-iteration waveform:

```bash
gtkwave test_results/div_32_once_20261011_230937.vcd \
        test_results/div_32_once_20261011_230937.gtkw
```

`ex_is_div_instruction` rises at 370 ns and falls when EX/MEM receives x7=33 at
1050 ns: `(1050-370)/20 = 34` complete EX periods. At 1030 ns the last iteration,
quotient/remainder capture, and raw done occur together, immediately releasing
`div_hazard`. Testbench logs sample 1 ns after each rising edge; these times are
actual VCD transitions, independently parsed from the dump. `vcd2fst` also
successfully converted this dump to FST.

Rerun the functional and waveform checks:

```bash
CCACHE_DIR=/tmp/div_once_ccache verilator --binary --timing -Wno-fatal \
  --top-module div_correctness_tb --Mdir /tmp/div_n2_unit -j 4 \
  vsrc/core/div.v tests/div_correctness_tb.sv
/tmp/div_n2_unit/Vdiv_correctness_tb
python3 tests/run_div_once.py --full-iterations
python3 tests/run_div_once.py --no-build --stall-tests
python3 tests/verify_div_merge.py --change div_n2
```

The first waveform command builds the current RTL; `--no-build` reuses that
binary. To reproduce the baseline comparison:

```bash
python3 tests/verify_div_merge.py --change div_n2 \
  --baseline-div test_results/div_n2_20261011_230833_div_before.v \
  --baseline-ex test_results/div_n2_20261011_230833_ex_before.v \
  --baseline-core test_results/div_n2_20261011_230833_riscv_core_before.v
```
