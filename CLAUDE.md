# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a RISC-V processor (graduation project) implemented in Verilog. The design implements RV32I + RV32M + Zicsr extensions using a **5-stage pipelined architecture** with data forwarding, hazard detection, and BTFNT static branch prediction.

### Instruction Set Support

| Extension | Instructions | Notes |
|-----------|-------------|-------|
| **RV32I** | All except FENCE/FENCE.I/ECALL/EBREAK | Load/store support unaligned access |
| **RV32M** | MUL, MULH, MULHSU, MULHU | 3-cycle Booth Radix-4 multiplier (4-cycle stall) |
| | DIV, DIVU, REM, REMU | 32-iteration divider (33-cycle stall) |
| **Zicsr** | CSRRW, CSRRS, CSRRC + immediate variants | mtvec, mepc, mcause, mstatus |
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
make verdi             # Open Verdi waveform viewer (testbench.fsdb)
make clean             # Remove build artifacts
make verdi_self_test   # Compile and open Verdi in one command
```

### Test Targets
```bash
make test-mul          # Test MUL/MULH/MULHSU/MULHU
make test-div          # Test DIV/DIVU/REM/REMU
make test-load-store   # Test load/store instructions
make test-unaligned    # Test unaligned memory access
make test-riscv        # Run single RISC-V official test
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
    ├── openmips.v (main processor core - 5-stage pipeline)
    │   ├── pc.v (Program Counter)
    │   ├── if_id_reg.v (IF/ID Pipeline Register)
    │   ├── id.v (Instruction Decode)
    │   ├── id_ex_reg.v (ID/EX Pipeline Register)
    │   ├── ex.v (Execute)
    │   ├── ex_dataram_reg.v (EX/MEM Pipeline Register)
    │   ├── dataram.v (Data Memory)
    │   ├── dataram_wb_reg.v (MEM/WB Pipeline Register)
    │   ├── wb.v (Write Back)
    │   ├── chj_registerfile (Register File)
    │   └── csr.v (Control and Status Registers)
    └── instrom.v (Instruction ROM)
```

### 5-Stage Pipeline Execution Flow

This is a **5-stage pipelined CPU** with pipeline registers between each stage:

1. **IF (Instruction Fetch)**: `pc.v` generates address → `instrom.v` supplies instruction → `if_id_reg.v` latches
2. **ID (Instruction Decode)**: `id.v` decodes instruction → reads register file → `id_ex_reg.v` latches
3. **EX (Execute)**: `ex.v` performs ALU operations, branch resolution, CSR operations → `ex_dataram_reg.v` latches
4. **MEM (Memory Access)**: `dataram.v` handles load/store operations → `dataram_wb_reg.v` latches
5. **WB (Write Back)**: `wb.v` selects result → writes to register file

**Key characteristics:**
- Pipeline registers between all stages (clocked sequential logic)
- Data forwarding from MEM and WB stages to EX stage to resolve hazards
- Hazard detection: load-use hazards, multiplier stalls
- Static branch prediction: BTFNT (Backward Taken, Forward Not Taken)
- Stall and flush control for pipeline bubbles
- Ideal CPI = 1 (one instruction completes per cycle in steady state)
- Branch misprediction penalty: 2 cycles
- Load-use hazard penalty: 1 cycle stall

### Key Modules

| Module | Description |
|--------|-------------|
| **openmips.v** | Top-level processor: pipeline control, hazard detection, data forwarding |
| **pc.v** | Program counter (base: `0x8000_0000`), handles stalls and redirects |
| **id.v** | Instruction decode, immediate extraction, BTFNT branch prediction |
| **ex.v** | ALU, branch resolution, mul/div units, CSR interface |
| **dataram.v** | Data memory (32KB), supports unaligned access |
| **csr.v** | CSR registers and trap handling |
| **instrom.v** | Instruction ROM (loads from hex file) |
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
- **Branch Prediction**: BTFNT (Backward Taken, Forward Not Taken) static prediction in ID stage
  - Backward branches (negative offset): predict taken (common for loops)
  - Forward branches (positive offset): predict not taken (common for if statements)
  - Prediction accuracy: 60-90% depending on workload
- **Branch Misprediction**: 2-cycle penalty (flush IF and ID stages)
- **JAL/JALR**: Unconditional jumps resolved in ID stage, 1-cycle penalty

**Stall and Flush Signals:**
- `stall_if_id`, `stall_id_ex`, `stall_ex_dataram`, `stall_dataram_wb`: Hold pipeline stage
- `flush_if_id`, `flush_id_ex`, `flush_ex_dataram`, `flush_dataram_wb`: Insert pipeline bubble (NOP)

## Important Notes

### Simulation Environment
- Clock: 20ns (50 MHz), Reset: 200ns, Total: 2200ns
- FSDB waveform dump always enabled

### File Paths
**CRITICAL**: Modules use absolute paths (e.g., `/home/jay/Desktop/graduation_project/`). Preserve these paths or update consistently across all files.

### Limitations
- Instruction ROM: 32 entries max (extend `instrom.v` for longer programs)
- Data memory: 32KB fixed
- No caches, static branch prediction only
- FENCE.I not implemented

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
| Instruction memory | `0x8000_0000` | 128 bytes (32 instructions) |
| `tohost` register | `0x8000_1000` | 4 bytes |
| Data segment | `0x8000_2000` | ~30KB |
