# Repository Guidelines

## Project Structure & Module Organization
- `rtl/`: active CPU RTL and main simulation flow.
- `rtl/vsrc/core`: pipeline and control modules (`id.v`, `ex.v`, `openmips.v`, `csr.v`, `registerfile.v`).
- `rtl/vsrc/mem`: instruction/data memory (`instrom.v`, `dataram_banked.v`).
- `rtl/vsrc/bus`, `rtl/vsrc/periph`: AXI-Lite bridge and UART-related blocks.
- `rtl/vsrc/instrom`: assembly inputs plus conversion tools (`llvm.sh`, `elf2hex.sh`).
- `verification/riscv-tests`: ISA regression inputs used by `run_tests.sh`.
- `verification/coremark`: CoreMark sources and RISC-V port.
- `iic/`, `practise/`, `rtl_backup/`: side projects and archives; keep CPU changes focused in `rtl/` unless required.

## Build, Test, and Development Commands
Run from `rtl/` unless noted:
- `make simv_build`: compile RTL with VCS without running.
- `make comp`: assemble default asm, build, and run simulation.
- `./run_single_test.sh rv32ui-p-add`: run one ISA test.
- `./run_tests.sh 'rv32u[i,m]-p-*'`: fast batch ISA regression.
- `./run_all_tests.sh [--no-build]`: unified UART smoke + ISA regression.
- `./run_bp_tests.sh [--build]`: branch predictor pattern suite.
- From repo root: `./run_coremark.sh`: build CoreMark ELF, generate HEX/data images, run sim.

## Coding Style & Naming Conventions
- Module names: lowercase with underscores (example: `branch_predictor`).
- Pipeline signals: `<src>_<dst>_<signal>` (example: `id_ex_alucex`, `ex_pc_pc_data`).
- Keep instruction/type constants in `rtl/vsrc/define.v` with uppercase macro names.
- Use explicit bit widths (`[31:0]`, `[4:0]`) and keep existing absolute `` `include `` path style.
- No auto-formatter is configured; preserve existing alignment and syntax style.

## Testing Guidelines
- Pass/fail follows `tohost` convention in testbench: `1` is pass; other non-zero values fail.
- For RTL changes, run:
  1. A focused check (`run_single_test.sh`).
  2. Relevant subsystem regression (`run_bp_tests.sh` or UART smoke tests).
  3. Full ISA batch (`run_tests.sh`).
- Save evidence in `rtl/test_results/` and reference summary logs in review notes.

## Commit & Pull Request Guidelines
- History shows short, action-focused messages (Chinese/English). Keep that style and add scope.
- Suggested format: `<scope>: <action>` (example: `core/ex: fix BLTU compare path`).
- Keep one logical change per commit.
- PRs should include: what changed, why, affected files, commands run, and key results (`TEST PASSED`/summary logs). Include waveform context for control-path changes.
