# Repository Guidelines

## Project Structure & Module Organization
- `rtl/`: active CPU RTL, simulation scripts, and regression entry points.
- `rtl/vsrc/core`: 5-stage core modules (`riscv_core.v`, stage registers, `branch_predictor.v`, `mul_3cycle.v`, `div.v`).
- `rtl/vsrc/mem`, `rtl/vsrc/dataram`, `rtl/vsrc/bus`, `rtl/vsrc/periph/uart`: memory model/tooling, AXI-Lite bridge, and UART peripherals.
- `rtl/vsrc/instrom`: assembly tests and ELF/HEX conversion scripts.
- `verification/riscv-tests` and `verification/coremark`: ISA and benchmark inputs.
- Historical/sandbox directories (`rtl_backup/`, `rtl_bank/`, `rtl_coremark_*`, `practise/`) should not receive active CPU changes unless explicitly requested.

## Build, Test, and Development Commands
Run from `rtl/` unless noted.
- `make simv_build`: compile RTL with VCS only.
- `make comp`: build and run the default asm flow.
- `make run_simv`: run an existing `simv` binary.
- `./run_single_test.sh rv32ui-p-add`: run one ISA test.
- `./run_tests.sh 'rv32u[i,m]-p-*'`: batch ISA regression.
- `./run_all_tests.sh [--no-build] [--skip-fencei]`: unified UART smoke + ISA suite.
- `./run_bp_tests.sh [--build]`, `./run_minstret_tests.sh`, `./run_perf_baseline.sh`, `./run_coremark.sh [ITERATIONS]`: subsystem, CSR, performance, and benchmark flows.

## Coding Style & Naming Conventions
- Use lowercase underscore module names (for example, `branch_predictor`).
- Keep stage-prefixed signal naming (`id_ex_*`, `ex_*`, `core_dataram_*`).
- Keep instruction/type macros in `rtl/vsrc/define.v` with uppercase names.
- Use explicit widths (for example, `[31:0]`, `[4:0]`) and preserve existing absolute `` `include `` style.
- No auto-formatter is configured; preserve current alignment and style.

## Testing Guidelines
- Pass/fail follows `tohost`: `1` means pass; other non-zero values mean fail.
- For RTL changes, run at least: focused test (`run_single_test.sh`), relevant subsystem regression, then broader ISA/unified regression.
- Store evidence under `rtl/test_results/` and include `[PERF]` (`mcycle`, `minstret`, `cpi`) when performance-sensitive.

## Commit & Pull Request Guidelines
- Prefer short, action-focused commit subjects in the style `<scope>: <action>` (example: `core/ex: fix BLTU compare path`).
- Keep one logical change per commit.
- PRs should include what changed, why, affected files, commands run, and key pass/fail summaries; add waveform context for control-path changes.
