# Repository Guidelines

## Project Structure & Module Organization

This project implements a five-stage RISC-V CPU in Verilog/SystemVerilog with branch prediction, multiplication, division, and UART peripherals.

- `rtl/vsrc/core/`: pipeline stages, forwarding, predictor, arithmetic units, and CSRs.
- `rtl/vsrc/{mem,dataram,bus,periph}/`: memory, AXI-Lite bridge, and peripherals.
- `rtl/vsrc/instrom/`: assembly tests and ELF/HEX conversion scripts; memory tooling lives in `rtl/vsrc/dataram/`.
- `verification/`: official RISC-V ISA tests and CoreMark sources.
- `rtl/test_results/`: regression logs and summaries; `docs/`: experiment documentation and figures.

Keep active CPU changes under `rtl/`. Do not modify historical directories such as `rtl_backup/`, `rtl_bank/`, `rtl_coremark_*`, or `practise/` unless explicitly requested.

## Build, Test, and Development Commands

Run commands from `rtl/`. Install VCS, Python 3, and the `riscv32-unknown-elf` toolchain; assembly helpers also require LLVM tools. Check compiler and simulator paths in `Makefile` for your environment.

- `make simv_build`: compile RTL without running tests.
- `make comp`: build and run the default `bp_tntn.s` assembly test.
- `make run_simv`: run the existing simulation binary.
- `./run.sh single rv32ui-p-add`: prepare memory and run one ISA test.
- `./run.sh all`: build and run UART smoke tests plus ISA regression.
- `./run.sh bp --build`: run branch predictor tests.
- `./run.sh coremark 1`: measure CoreMark performance.
- `make verdi`: inspect existing waveforms.

`make clean` deletes simulation artifacts and `test_results`; preserve needed evidence first.

## Coding Style & Naming Conventions

Use two-space indentation and preserve surrounding alignment; no automatic formatter is prescribed. Use lowercase underscore module names, stage-prefixed signals (`id_ex_*`), explicit widths (`[31:0]`), and named port connections. Define uppercase instruction macros in `rtl/vsrc/define.v`. Follow existing include conventions and document complex control logic. VCS enables lint warnings with `+lint=TFIPC-L`.

## Communication & Diagrams

Use plain-text boxes and connecting lines inside fenced `text` code blocks for module connection diagrams, architecture diagrams, and data-path diagrams, both in responses and project documentation. Do not use Mermaid `flowchart` format for these diagrams.

## Testing Guidelines

For RTL changes, run a focused test, the relevant subsystem suite, then broad regression. Add assembly cases alongside existing tests, using patterns such as `uart_*.s`. ISA success requires `tohost = 1`; zero is incomplete, and other nonzero values indicate failure. Save timestamped evidence under `rtl/test_results/`. Document any `--skip-fencei` exclusion. Performance changes require CoreMark and `mcycle`, `minstret`, and CPI comparisons.

## Commit & Pull Request Guidelines

History mixes descriptive Chinese messages and prefixed commits. Prefer atomic `<scope>: <action>` messages, such as `core/ex: fix BLTU compare path`. PRs should explain the problem, changes, affected files, test commands/results, and relevant issues. Include performance comparisons for optimizations and waveform evidence for control-path changes.
