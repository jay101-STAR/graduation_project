# Single-division waveforms

## Current N+2 handshake

Run from `rtl/`:

```bash
python3 tests/run_div_once.py --stall-tests
```

The runner builds the current RTL with Verilator, checks three single-division
programs and five memory-stall schedules, and saves VCD, GTKWave, and log files.
It restores the memory images after the run. All cases check the quotient,
remainder, expected EX duration, exactly one start, exactly one EX/MEM
acceptance, and `tohost=1`. While a completed result is waiting for a memory
stall to end, the bench also checks that the result and pending completion are
retained and no new division starts.

Measured on 2026-10-11 after the N+2 handshake change:

| Program | Operation | Iterations N | EX high interval (ns) | EX periods | Hazard periods |
| --- | --- | ---: | --- | ---: | ---: |
| div_once | signed 100 / 3 = 33, remainder 1 | 7 | 370--550 | 9 | 8 |
| div_fast_once | signed 100 / 1 = 100, remainder 0 | fast path | 370--430 | 3 | 2 |
| div_long_once | unsigned 0xffffffff / 3 = 1431655765, remainder 0 | 31 | 370--1030 | 33 | 32 |

These are measured VCD transitions, with a 20 ns clock period. Ordinary
division occupies EX for `1 input-capture + N iterations + 1 EX/MEM transfer =
N+2` periods when no other pipeline stall blocks it. The divider's final
iteration captures the quotient, remainder, and raw done together. Raw done
now makes `ex_div_done` valid immediately; it no longer needs a separate EX
completion-capture period. Fast paths occupy three periods.

```bash
gtkwave test_results/div_once_20261011_231304.vcd \
        test_results/div_once_20261011_231304.gtkw
```

For 100 / 3, compare `ex_is_div_instruction`, `div_hazard`, `div_start`,
`div_done_raw`, `div_done_latched`, `div_result_valid`, `div_result_accept`,
`ex_can_advance`, `cnt`, and the EX/MEM destination/result. The divider captures
inputs at 390 ns, iterates on seven rising edges from 410 through 530 ns,
and EX/MEM captures x7=33 at 550 ns. Without another stall,
`div_done_latched` stays zero: raw completion is accepted directly. With a
stall it becomes one, preserving completion after raw done clears.

Evidence: `test_results/div_wave_summary_20261011_231304.txt` and
[`div_n2_validation.md`](div_n2_validation.md).

## Full 32-iteration waveform

Run from `rtl/`:

```bash
python3 tests/run_div_once.py --full-iterations
```

This runs the single signed `100 / 3` instruction in `div_once.s` while the
standalone testbench forces `div_skip_count=0`. Both counter initialization and
initial dividend shifting therefore use zero skip. The CPU RTL is unchanged.
With prefix skipping enabled, changing operands alone cannot make this divider
take 32 ordinary iterations. Full-iteration mode checks 32 iteration edges,
one start, one acceptance, quotient 33, remainder 1, 34 EX periods, and
33 hazard periods after the N+2 handshake change.

Measured on 2026-10-11: EX high from 370 to 1050 ns, hazard high from 370 to
1030 ns. The VCD high intervals agree with the bench's edge counters.

```bash
gtkwave test_results/div_32_once_20261011_230937.vcd \
        test_results/div_32_once_20261011_230937.gtkw
```

Observe `cnt`: initialized to 0 at 390 ns, then incremented on 32 edges
from 410 through 1030 ns, reaching 32. Raw completion and quotient/remainder are now captured at that same
1030 ns edge; hazard immediately deasserts; EX/MEM receives the result at 1050 ns.
This waveform uses a testbench override and does not represent the normal
prefix-skipping configuration below.

The earlier final-iteration merge alone occupied 35 EX periods, measured
370--1070 ns in `div_32_once_20261011_123256.vcd`. Its extra completion-capture
period has now been removed.

## Historical measurements before the final-iteration merge

These are historical measurements; `python3 tests/run_div_once.py` now tests
the current N+2 behavior above.
The runner builds a standalone Verilator bench, runs three programs with one
division each, saves timestamped VCD/GTKWave/log files, and restores the previous
memory images. Each program checks the quotient through an immediately dependent
instruction before setting register tohost x3 to 1. The bench also checks that
the division starts exactly once and that EX/MEM receives the expected result.
CPU RTL and the existing VCS testbench are unchanged.

Evidence from 2026-10-07: `test_results/div_wave_summary_20261007_230346.txt`.
Clock period: 20 ns. VCD transitions were parsed independently of bench logs.

| Program | Operation | EX high interval (ns) | EX periods | Hazard high interval (ns) | Hazard periods |
| --- | --- | --- | ---: | --- | ---: |
| div_once | signed 100 / 3 = 33 | 370--590 | 11 | 370--570 | 10 |
| div_fast_once | signed 100 / 1 = 100 | 370--450 | 4 | 370--430 | 3 |
| div_long_once | unsigned 0xffffffff / 3 = 1431655765 | 370--1070 | 35 | 370--1050 | 34 |

All three tests passed. Bench logs sample 1 ns after each rising edge to allow
nonblocking assignments to settle; VCD times above are actual transition times.

Open the ordinary case:

```bash
gtkwave test_results/div_once_20261007_230346.vcd \
        test_results/div_once_20261007_230346.gtkw
```

Replace `div_once` with `div_fast_once` or `div_long_once` for the other cases.
The save files select the clock, EX identity, hazard, completion handshake,
EX/MEM destination/result, divider state, iteration count, and quotient/remainder.

For 100 / 3, the prefix skip count is 25, so there are 7 actual iterations:

| Rising edge (ns) | Event |
| ---: | --- |
| 370 | Division enters EX |
| 390 | Input capture; cnt initialized to 25 |
| 410--530 | Seven shift/subtract iterations; cnt advances to 32 |
| 550 | Quotient/remainder capture; raw done asserted |
| 570 | EX latches completion; hazard deasserted |
| 590 | EX/MEM receives quotient 33 for x7 |

EX residence is N+4 periods; hazard is N+3, where N=32-skip_count for the
ordinary path. Fast paths use 4 and 3 respectively. With the current fast paths,
an ordinary path cannot have skip_count=0: a magnitude-1 divisor takes the fast
path, while an ordinary divisor has highest-set-bit index at least 1. Therefore
the ordinary path has at most 31 iterations, giving at most 35 EX periods without
additional memory stalls, rather than the earlier hypothetical 36-period case.
