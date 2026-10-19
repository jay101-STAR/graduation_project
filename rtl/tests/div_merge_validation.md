# Final-iteration divider optimization: 2026-10-11

`vsrc/core/div.v` captures quotient, remainder, and completion at the end of
the last ordinary iteration (`cnt == 31`). The new `dividend_next` wire is the
shift/subtract result for that iteration; sign recovery reads this wire rather
than the previous value of the iteration register. A completion guard holds
all results while WORK transitions to DONE, preventing an additional iteration.

The arithmetic algorithm, prefix skip, and fast paths retain their behavior.
Ordinary EX residence is now N+3 periods and hazard duration N+2, where N is
the actual iteration count. No synthesis timing measurement was performed;
the final shift/subtract and sign recovery now share a single combinational path.

## Validation

VCS could not connect to its license server, so all successful checks used
Verilator 5.027. These simulations do not replace four-state VCS validation or
FPGA timing analysis. The official testbench was reused for ISA/UART/CoreMark,
with only its unsupported FSDB dump calls removed in a temporary copy.

| Check | Result |
| --- | --- |
| Standalone arithmetic | 2,339 signed/unsigned quotient/remainder cases PASS |
| Corner cases | Zero divisor, INT_MIN/-1, all sign combinations, powers of two, a<b PASS |
| Lifecycle | Output stable after completion, consecutive requests, reset during work PASS |
| Focused CPU test | rv32um-p-div PASS |
| RV32M suite | 8/8 PASS |
| Full regression | 50 ISA + 6 UART = 56/56 PASS; no exclusions |
| Single-instruction waveforms | Ordinary, fast, long, forced 32-iteration cases PASS |
| CoreMark CRCs | list/matrix/state PASS before and after |

Final regression/unit evidence is in `test_results/div_merge_20261011_123230_*`.
Before/after simulations were serialized because memory images are shared.
An initial overlapping baseline run reported missing CRC output, and an
overlapping waveform run aborted; those preliminary runs are excluded. The
reproducible drivers now lock image preparation and simulation together.

## Measured waveform comparison

Clock period: 20 ns. Both log edge counters and VCD high intervals were checked.

| Case | EX periods before -> after | Hazard periods before -> after |
| --- | --- | --- |
| 100/3, seven iterations | 11 -> 10 | 10 -> 9 |
| 100/1, fast path | 4 -> 4 | 3 -> 3 |
| Unsigned 0xffffffff/3 | 35 -> 34 | 34 -> 33 |
| 100/3, testbench forces 32 iterations | 36 -> 35 | 35 -> 34 |

The forced full-iteration VCD is `test_results/div_32_once_20261011_123256.vcd`.
The ordinary/fast/long VCDs use timestamp `20261011_123535`. Each has a matching
GTKWave save file selecting the relevant signals. Prior waveforms are historical.

## CoreMark comparison

Both builds used the same simulator, GCC options, one iteration, and measurement
window. These short runs are for optimization comparison, not official scores.

| Metric | Before | After |
| --- | ---: | ---: |
| Region mcycle | 404358 | 404358 |
| Region minstret | 287265 | 287265 |
| Region CPI | 1.4076 | 1.4076 |
| Region divider wait cycles | 0 | 0 |
| Whole-program mcycle | 2345096 | 2345095 |
| Whole-program minstret | 307901 | 307901 |
| Whole-program CPI (rounded) | 7.6164 | 7.6164 |

The measured region contains no division, so it cannot demonstrate the divider
speedup. Evidence: `coremark_20261011_123517_840551.log` (before),
`coremark_20261011_123558_113087.log` (after).

## Reproduce

From `rtl/`:

```bash
python3 tests/run_div_once.py --full-iterations
python3 tests/run_div_once.py --no-build
verilator --binary --timing -Wno-fatal --top-module div_correctness_tb \
  --Mdir /tmp/div_merge_unit -j 4 vsrc/core/div.v tests/div_correctness_tb.sv
/tmp/div_merge_unit/Vdiv_correctness_tb
python3 tests/verify_div_merge.py
```

Set `CCACHE_DIR=/tmp/div_once_ccache` on Verilator commands if the environment's
default compiler cache directory is not writable. To compare against the saved
old implementation, run `tests/verify_div_merge.py --baseline-div
test_results/div_merge_20261011_123230_before.v`.
