# Repository Guidelines

## Project Structure & Module Organization
- `rtl/`: active CPU RTL, simulation scripts, and regression entry points.
- `rtl/vsrc/core`: 5-stage pipeline core (`riscv_core.v`, `pc.v`, `if_id_reg.v`, `id.v`, `id_ex_reg.v`, `ex.v`, `ex_dataram_reg.v`, `dataram_wb_reg.v`, `wb.v`, `csr.v`, `registerfile.v`, `branch_predictor.v`, `mul_3cycle.v`, `div.v`).
- `rtl/vsrc/mem`: memory model (`dataram_banked.v`) with `tohost` observation path.
- `rtl/vsrc/dataram`: memory image tooling and bank artifacts (`extract_data.sh`, `split_instrom_to_banks.sh`, `gen_banked_coe.py`, `bank*.hex`, `inst_bank*.hex`).
- `rtl/vsrc/bus`: AXI-Lite bridge (`mem_to_axi_lite_bridge.v`).
- `rtl/vsrc/periph/uart`: UART AXI-Lite slave and RX/TX blocks.
- `rtl/vsrc/instrom`: assembly tests and conversion tools (`llvm.sh`, `asm2hex.sh`, `elf2hex.sh`, `bp_tests/`, `minstret_tests/`, UART smoke asm files).
- `verification/riscv-tests`: ISA and benchmark inputs used by regression scripts.
- `verification/coremark`: CoreMark sources and RISC-V port.
- `iic/`, `practise/`, `rtl_backup/`, `rtl_bank/`, `rtl_coremark_*/`: side projects/history snapshots; keep active CPU changes in `rtl/` unless explicitly requested.

## Build, Test, and Development Commands
Run from `rtl/` unless noted:
- `make simv_build`: compile RTL with VCS only.
- `make comp`: build and run default asm flow.
- `make run_simv`: run existing `simv`.
- `./run_single_test.sh rv32ui-p-add`: run one ISA ELF test.
- `./run_tests.sh 'rv32u[i,m]-p-*'`: fast ISA batch regression (supports `SKIP_TEST_REGEX` env).
- `./run_all_tests.sh [--no-build] [--skip-fencei]`: unified UART smoke + ISA regression.
- `./run_bp_tests.sh [--build]`: branch predictor pattern suite from `vsrc/instrom/bp_tests`.
- `./run_minstret_tests.sh [--test <name>]`: CSR/minstret-focused regression from `vsrc/instrom/minstret_tests`.
- `./run_perf_baseline.sh [--build] [--tests "..."]`: collect `mcycle/minstret/cpi` baseline.
- `./run_coremark.sh [ITERATIONS]`: build CoreMark ELF, generate memory images, run sim.

## Coding Style & Naming Conventions
- Module names: lowercase with underscores (example: `branch_predictor`).
- Pipeline/control signals: keep stage-prefixed naming (example: `id_ex_alucex`, `ex_pc_pc_data`, `core_dataram_wen`).
- Keep instruction/type constants in `rtl/vsrc/define.v` with uppercase macro names.
- Use explicit bit widths (`[31:0]`, `[4:0]`) and keep existing absolute `` `include `` path style.
- Keep compatibility with existing bash/python tooling under `rtl/vsrc/instrom` and `rtl/vsrc/dataram`; avoid ad-hoc one-off conversion flows when scripts already exist.
- No auto-formatter is configured; preserve existing alignment and syntax style.

## Testing Guidelines
- Pass/fail follows `tohost` convention in testbench: `1` is pass; other non-zero values fail.
- For RTL changes, run:
  1. A focused check (`run_single_test.sh`).
  2. Relevant subsystem regression (`run_bp_tests.sh`, `run_minstret_tests.sh`, UART smoke via `run_all_tests.sh`, or `run_perf_baseline.sh`).
  3. Full ISA batch (`run_tests.sh`) or unified batch (`run_all_tests.sh`).
- Save evidence in `rtl/test_results/` and reference summary logs in review notes.
- For performance-sensitive changes, include `[PERF]` line evidence (`mcycle`, `minstret`, `cpi`) from generated logs.

## Commit & Pull Request Guidelines
- History shows short, action-focused messages (Chinese/English). Keep that style and add scope.
- Suggested format: `<scope>: <action>` (example: `core/ex: fix BLTU compare path`).
- Keep one logical change per commit.
- PRs should include: what changed, why, affected files, commands run, and key results (`TEST PASSED`/summary logs under `rtl/test_results/`). Include waveform context for control-path changes.

## Agent Collaboration Rule
- Before running any command/script/test or modifying any file, the AI agent must ask for and obtain explicit user approval.
- No actions should be executed based on inferred consent from context; approval must be clear in the current conversation.
- If the user asks to pause/stop, the agent must halt immediately and wait for the next explicit approval before continuing.
- The AI agent must always answer in Chinese unless the user explicitly requests another language.
