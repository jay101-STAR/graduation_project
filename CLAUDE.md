# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a RISC-V processor (graduation project) implemented in Verilog. The design implements RV32I + RV32M + Zicsr extensions using a **5-stage pipelined architecture** with data forwarding, hazard detection, and a dynamic branch predictor (gshare PHT + BTB).

### Instruction Set Support

| Extension | Instructions | Notes |
|-----------|-------------|-------|
| **RV32I** | Main integer/load-store/branch/jump/system subset used by regression | Includes FENCE.I and trap path (ECALL/EBREAK) in current RTL |
| **RV32M** | MUL, MULH, MULHSU, MULHU | 3-cycle Booth Radix-4 multiplier (4-cycle stall) |
| | DIV, DIVU, REM, REMU | 32-iteration divider (33-cycle stall) |
| **Zicsr** | CSRRW, CSRRS, CSRRC + immediate variants | mtvec, mepc, mcause, mstatus, mie, cycle/minstret |
| | MRET | Exception return |

## Build and Simulation Commands

All commands run from the `rtl/` directory.

### Prerequisites
- Synopsys VCS (with GCC 4.8)
- Verdi waveform viewer
- LLVM toolchain: `llvm-mc`, `llvm-objcopy` (for RV32IM)
- GNU RISC-V toolchain: `riscv32-unknown-elf-as`, `riscv32-unknown-elf-objcopy`

### Core Commands
```bash
make comp              # Assemble instrom.s, compile with VCS, run simulation
make simv_build        # Compile RTL with VCS only
make run_simv          # Run existing simv
make coremark          # Run CoreMark flow (rtl/run_coremark.sh)
make verdi             # Open Verdi waveform viewer (testbench.fsdb)
make clean             # Remove build artifacts
make verdi_self_test   # Compile and open Verdi in one command
```

### Test Targets
```bash
./run_single_test.sh rv32ui-p-add         # Run one ISA test
./run_tests.sh 'rv32u[i,m]-p-*'           # Batch ISA regression
./run_bp_tests.sh [--build]               # Branch predictor pattern suite
./run_all_tests.sh [--no-build]           # UART smoke + ISA regression
./run_minstret_tests.sh                    # CSR minstret regression
./run_coremark.sh [ITERATIONS]            # CoreMark compile + sim flow
```

### Custom Assembly Workflow
```bash
# Option 1: Edit the Makefile comp target to use your .s file
# Option 2: Manual workflow
cd rtl/vsrc/instrom
./llvm.sh your_test.s                    # Creates your_test.hex
cp your_test.hex instrom.hex             # Set as active program
cd ../..
make comp                                 # Recompile and run
```

Assembly toolchains:
- `llvm.sh`: LLVM (llvm-mc/objcopy) - supports RV32IM
- `asm2hex.sh`: GNU (riscv32-unknown-elf-as/objcopy)

## Architecture Overview

### Top-Level Hierarchy
```
testbench.v
└── top.v
    ├── riscv_core.v (main 5-stage pipeline core)
    │   ├── pc.v / if_id_reg.v / id.v / id_ex_reg.v
    │   ├── ex.v / ex_dataram_reg.v / dataram_wb_reg.v / wb.v
    │   ├── registerfile.v / csr.v / branch_predictor.v
    │   └── mul_3cycle.v / div.v
    ├── dataram_banked.v (shared instruction/data BRAM)
    ├── mem_to_axi_lite_bridge.v (CPU local mem <-> AXI-Lite)
    └── axi_lite_uart_slave.v (UART MMIO peripheral)
```

### 5-Stage Pipeline Execution Flow

This is a **5-stage pipelined CPU** with pipeline registers between each stage:

1. **IF (Instruction Fetch)**: `pc.v` generates address → `dataram_banked.v` instruction port supplies instruction → `if_id_reg.v` latches
2. **ID (Instruction Decode)**: `id.v` decodes instruction → reads register file → `id_ex_reg.v` latches
3. **EX (Execute)**: `ex.v` performs ALU operations, branch resolution, CSR operations → `ex_dataram_reg.v` latches
4. **MEM (Memory Access)**: `dataram_banked.v` (RAM) / `mem_to_axi_lite_bridge.v` (MMIO) handle load/store operations → `dataram_wb_reg.v` latches
5. **WB (Write Back)**: `wb.v` selects result → writes to register file

**Key characteristics:**
- Pipeline registers between all stages (clocked sequential logic)
- Data forwarding from MEM and WB stages to EX stage to resolve hazards
- Hazard detection: load-use hazards, multiplier stalls
- Dynamic branch prediction: gshare direction predictor + 2-way BTB
- Stall and flush control for pipeline bubbles
- Ideal CPI = 1 (one instruction completes per cycle in steady state)
- Branch misprediction penalty: 2 cycles
- Load-use hazard penalty: 1 cycle stall

### Key Modules

| Module | Description |
|--------|-------------|
| **riscv_core.v** | Top-level processor core: pipeline control, hazard detection, forwarding |
| **pc.v** | Program counter (base: `0x8000_0000`), handles stalls and redirects |
| **id.v** | Instruction decode and immediate extraction |
| **ex.v** | ALU, branch resolution, mul/div units, CSR interface |
| **branch_predictor.v** | gshare PHT + BTB branch predictor |
| **dataram_banked.v** | Banked BRAM memory model with unaligned access support |
| **csr.v** | CSR registers and trap handling |
| **mem_to_axi_lite_bridge.v** | MMIO bridge to AXI-Lite peripherals |
| **axi_lite_uart_slave.v** | UART MMIO device |
| **registerfile.v** | 32 registers (x0-x31), dual-read/single-write |

**Pipeline Registers** (all support stall/flush):
- `if_id_reg.v` → `id_ex_reg.v` → `ex_dataram_reg.v` → `dataram_wb_reg.v`

**RV32M Modules**:
- `mul_3cycle.v`: Booth Radix-4 multiplier with Wallace tree
- `div.v`: 32-iteration iterative divider

### Instruction Type Encoding (define.v)

Two-level classification:
- **aluc** (4-bit): Instruction category (R, I, S, B, JAL, LUI, etc.)
- **alucex** (8-bit): Specific operation (ADD, SUB, BEQ, etc.)

### Signal Naming Conventions
- Pattern: `source_dest_signal` (e.g., `pc_id_pc`, `id_ex_rs1_data`, `ex_reg_rd_data`)
- Suffixes: `ren`/`wen` (enable), `raddr`/`waddr` (address), `rdata`/`wdata` (data)

### Pipeline Hazards and Control

**Data Hazards:**
- **Data Forwarding**: Results from MEM and WB stages forwarded to EX stage to resolve RAW hazards
- **Load-Use Hazard**: 1-cycle stall when instruction in EX depends on load result in MEM stage
- **Multiplier Hazard**: 4-cycle stall for MUL/MULH/MULHSU/MULHU instructions (3 computation stages + 1 register delay)
- **Divider Hazard**: 33-cycle stall for DIV/DIVU/REM/REMU instructions (32 iterations + 1 result cycle)

**Control Hazards:**
- **Branch Prediction**: Dynamic predictor in IF stage
  - gshare direction predictor (8-bit GHR + 2-bit saturating counters)
  - 2-way set-associative BTB for target prediction
  - Predictor updated from EX stage branch outcomes
- **Branch Misprediction**: 2-cycle penalty (flush IF and ID stages)
- **JAL/JALR**: Unconditional jumps resolved in ID stage, 1-cycle penalty

**Stall and Flush Signals:**
- `stall_if_id`, `stall_id_ex`, `stall_ex_dataram`, `stall_dataram_wb`: Hold pipeline stage
- `flush_if_id`, `flush_id_ex`, `flush_ex_dataram`, `flush_dataram_wb`: Insert pipeline bubble (NOP)

## Important Notes

### Simulation Environment
- Clock: 20ns (50 MHz), Reset: 200ns
- Testbench timeout default: `4,000,000 ns` (supports override via `+timeout_ns=<N>`)
- FSDB waveform dump always enabled

### File Paths
**CRITICAL**: Modules use absolute paths (e.g., `/home/jay/Desktop/graduation_project/`). Preserve these paths or update consistently across all files.

### Limitations
- Single-issue, in-order 5-stage pipeline
- No cache hierarchy in current RTL
- External interrupt delivery path to core is not fully wired yet
- Simulation/build depends on VCS license availability

### Testing and Verification

#### RISC-V Official Test Suite
Tests located in `verification/riscv-tests/isa/`.

```bash
# First compile to generate simv
make comp

# Run tests (default pattern: rv32um-p-*)
./run_tests.sh                     # Run M extension tests
./run_tests.sh "rv32ui-p-*"        # All RV32UI tests
./run_tests.sh "rv32ui-p-add"      # Single test
./run_tests.sh "rv32ui-p-b*"       # All branch tests
```

**Test completion detection:**
- Tests write to `tohost` at `0x80001000`
- `tohost = 1`: PASS, `tohost != 1`: FAIL (value = failing test case)

**Results:** `rtl/test_results/summary_*.txt`, `failed_tests_*.txt`, `<test>.log`

## Debugging

### Common Issues
| Problem | Check |
|---------|-------|
| Compilation fails | VCS/GCC 4.8 install, absolute paths in `include` |
| X values | `sim.log` for X propagation, uninitialized regs |
| Test hangs | PC incrementing in waveform, `tohost_value` signal |

### Key Signals for Waveform Analysis
- `pc_id_pc`: Program counter
- `id_ex_alucex`: Current instruction in EX
- `ex_reg_rd_wen/data`: Register writeback
- `stall_*`, `flush_*`: Pipeline control
- `tohost_value`: Test completion
- `mul_start/done/busy`: Multiplier state

### Memory Layout
| Region | Address | Size |
|--------|---------|------|
| Instruction/Data banked BRAM base | `0x8000_0000` | Address space mapped in `dataram_banked.v` (banked BRAM model) |
| `tohost` register | `0x8000_1000` | 4 bytes |
| UART MMIO base | `0x1000_0000` | AXI-Lite slave registers |
