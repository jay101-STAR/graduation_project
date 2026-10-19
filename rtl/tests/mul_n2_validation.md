# MUL N+2 handshake: 2026-10-11

`ex.v` now exposes the result as valid on `mul_inflight && mul_done_raw`, or
through `mul_done_latched` if completion is pending. `riscv_core.v` supplies
`ex_can_advance = !stall_ex_dataram`. On the edge when EX/MEM accepts a valid
MUL result, EX clears both inflight and pending completion. If the memory path
is blocked, completion stays pending and inflight prevents another start.
The multiplier's three arithmetic stages are unchanged; DIV keeps the previously
validated final-iteration optimization and its existing completion handshake.

Without additional memory waits, MUL now occupies five complete EX periods:
input capture (1), arithmetic (3), and transfer to EX/MEM (1). The former
separate completion-latch wait is removed. `mul_hazard` lasts four periods.

## Validation

Successful simulations used Verilator 5.027. VCS rebuild could not connect to
its license server; the old `simv` must not be assumed to contain these changes.
The regression driver uses a temporary copy of the official testbench, removing
only unsupported FSDB dumping. RAM preparation and simulation are serialized,
and all prior memory images are restored after testing.

| Check | Result |
| --- | --- |
| Single MUL 7*9 | PASS; one start and one acceptance; product 63; EX 6 -> 5 periods |
| Four memory wait schedules | PASS; early, across completion, during raw done, and long waits |
| Pending completion | Product and completion retained; no repeated start; one acceptance |
| Dependency/mixed-operation assembly | PASS; dependent/consecutive MUL, same destination, x0, MULH/MULHSU/MULHU, MUL/DIV/REM, load/store dependencies |
| Focused rv32um-p-mul | 1/1 PASS |
| RV32M | 8/8 PASS |
| Full ISA/UART | 50 ISA + 6 UART = 56/56 PASS, no exclusions |
| CoreMark | list/matrix/state CRC and measurement consistency PASS before and after |

Evidence:

- `test_results/mul_n2_20261011_225143_baseline_run.log`
- `test_results/mul_n2_20261011_225143_after_run.log`
- `test_results/mul_handshake_20261011_225442.log`
- `test_results/isa_summary_20261011_225500_209606.txt`
- `test_results/all_summary_20261011_225503_898186.txt`
- `test_results/mul_wave_summary_20261011_225352.txt`

The baseline snapshots are `mul_n2_20261011_225143_ex_before.v` and
`mul_n2_20261011_225143_core_before.v` under `test_results/`. Both builds include
the same already-optimized divider, so the comparison isolates the MUL handshake.

## CoreMark comparison

Same compiler flags, one iteration, same simulator, and same measured region.
These are short-run comparisons, not official CoreMark scores.

| Metric | Before | After |
| --- | ---: | ---: |
| Region mcycle | 404358 | 394962 |
| Region minstret | 287265 | 287265 |
| Region CPI | 1.4076 | 1.3749 |
| Multiply wait cycles | 46980 | 37584 |
| Divide wait cycles | 0 | 0 |
| Load-use cycles | 21737 | 21737 |
| Whole-program mcycle | 2345095 | 2335602 |
| Whole-program minstret | 307901 | 307901 |
| Whole-program CPI | 7.6164 | 7.5856 |

The region saves 9396 cycles (2.32%); multiplication wait decreases by 20%.
At equal clock frequency, region execution is about 2.38% faster. No synthesis
timing was run: arithmetic logic is unchanged, but the control path from raw
completion to pipeline enables still needs hardware timing analysis.

CoreMark evidence: `coremark_20261011_225442_318129.log` (before) and
`coremark_20261011_225528_308589.log` (after).

## Waveform

```bash
cd /home/jay/Desktop/graduation_project/rtl
gtkwave test_results/mul_once_20261011_225352.vcd \
        test_results/mul_once_20261011_225352.gtkw
```

At 370 ns the MUL enters EX. At 450 ns product 63 and raw done become valid;
MUL hazard deasserts immediately. At 470 ns EX/MEM accepts the result. Thus EX
residence is 100 ns / 20 ns = 5 periods. Bench logs sample 1 ns after each edge;
VCD transition times were independently checked. Under a stall, observe
`mul_done_latched`, `mul_inflight`, `mul_result_valid`, and `mul_result_accept`.

## Reproduce

From `rtl/`:

```bash
python3 tests/run_mul_once.py
python3 tests/verify_div_merge.py --change mul_n2
```

To reproduce the baseline with its saved RTL snapshots:

```bash
python3 tests/verify_div_merge.py --change mul_n2 \
  --baseline-ex test_results/mul_n2_20261011_225143_ex_before.v \
  --baseline-core test_results/mul_n2_20261011_225143_core_before.v
```
