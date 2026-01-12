# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a RISC-V processor (graduation project) implemented in Verilog. The design implements a subset of the RV32I instruction set with some RV32M (multiply/divide) support and Zicsr (CSR) extensions. The processor uses a classic 5-stage pipeline architecture.

## Build and Simulation Commands

All commands should be run from the `/rtl` directory:

### Compile and Run Simulation
```bash
cd rtl
make comp
```
This command:
1. Assembles the assembly file (default: `vsrc/instrom/instrom.s`) using `llvm.sh` script
2. Compiles all Verilog sources with Synopsys VCS
3. Runs simulation with `simv`, outputting to `sim.log`

### View Waveforms
```bash
cd rtl
make verdi
```
Opens Verdi waveform viewer to inspect `testbench.fsdb` (generated during simulation).

### Clean Build Artifacts
```bash
cd rtl
make clean
```
Removes compilation artifacts, logs, and generated files (but preserves source code).

### Assembly Workflow
To test different assembly programs:
1. Edit or create a `.s` file in `rtl/vsrc/instrom/` (e.g., `csrrs_test.s`)
2. Modify the Makefile `comp` target to use your assembly file:
   ```makefile
   comp:
       ./vsrc/instrom/llvm.sh ./vsrc/instrom/your_test.s
       $(VCS)
       ./simv -l sim.log
   ```
3. Run `make comp`

Two assembly toolchains are available:
- `llvm.sh`: Uses LLVM toolchain (llvm-mc, llvm-objcopy) for RV32IM
- `asm2hex.sh`: Uses GNU RISC-V toolchain (riscv32-unknown-elf-as/objcopy)

Both generate `.hex` files that are loaded by the `instrom` module at line 12 of `rtl/vsrc/instrom.v`.

## Architecture Overview

### Top-Level Hierarchy
```
testbench.v
└── top.v
    ├── openmips.v (main processor core)
    │   ├── pc.v (Program Counter)
    │   ├── id.v (Instruction Decode)
    │   ├── ex.v (Execute)
    │   └── chj_registerfile (Register File)
    └── instrom.v (Instruction ROM)
```

### Pipeline Stages (Classic 5-Stage)
1. **IF (Instruction Fetch)**: `pc.v` generates addresses, `instrom.v` supplies instructions
2. **ID (Instruction Decode)**: `id.v` decodes instructions, reads register file
3. **EX (Execute)**: `ex.v` performs ALU operations, branch resolution, CSR operations
4. **MEM (Memory)**: Currently not implemented as a separate stage (no data memory)
5. **WB (Write Back)**: Register file writeback happens directly from EX stage

### Key Modules

**openmips.v** (rtl/vsrc/openmips.v:1)
- Top-level processor module connecting all pipeline stages
- Implements inter-stage signal routing (pc→id, id→ex, ex→regfile, ex→pc)

**pc.v** (rtl/vsrc/pc.v:2)
- Manages program counter with base address `0x8000_0000`
- Handles PC updates: sequential (+4) or branch/jump targets from EX stage
- Uses generic `Reg` module for flip-flops

**id.v** (rtl/vsrc/id.v:3)
- Decodes 32-bit RISC-V instructions using func3, func7, and opcode fields
- Generates control signals: `aluc` (4-bit instruction type), `alucex` (8-bit detailed operation)
- Performs immediate value extraction and sign extension (I, S, B, U, J types)
- Computes branch conditions for B-type instructions
- Reads from register file (rs1, rs2)

**ex.v** (rtl/vsrc/ex.v:3)
- Executes ALU operations based on `alucex` signals
- Handles PC redirection: JAL, JALR, branches, CSR traps, MRET
- Interfaces with CSR module (Control and Status Registers)
- Priority for PC redirection: trap > mret > jal/jalr > branch
- Writes results to register file (rd)

**instrom.v** (rtl/vsrc/instrom.v:3)
- 32-entry instruction memory (128 bytes total)
- Loads instructions from hex file at initialization (`$readmemh`)
- Address mapping: subtracts base address `0x8000_0000` and shifts right by 2

**registerfile.v** (rtl/vsrc/registerfile.v:1)
- 32 general-purpose registers (x0-x31)
- x0 is hardwired to zero
- Dual-read, single-write ports

### Instruction Type Encoding (define.v)

The processor uses a two-level instruction classification:
- **aluc** (4-bit): Broad instruction category (R, I, S, B, JAL, LUI, etc.)
- **alucex** (8-bit): Specific operation within category (ADD, SUB, XOR, BEQ, etc.)

See `rtl/vsrc/define.v` for complete encoding definitions (lines 6-61).

### Signal Naming Conventions
- Format: `source_dest_signal` (e.g., `pc_id_pc`, `id_ex_rs1_data`, `ex_reg_rd_data`)
- `ren`: Read enable
- `wen`: Write enable
- `raddr`/`waddr`: Read/write address
- `rdata`/`wdata`: Read/write data

## Important Notes

### Simulation Environment
- Testbench runs for 2200ns (200ns reset + 2000ns active)
- Clock period: 20ns (50 MHz)
- FSDB waveform dump is always enabled (see testbench.v:27-28)

### VCS Compiler Flags
The Makefile uses specific VCS options:
- `-debug_acc+dmptf -debug_region+cell+encrypt`: Enable waveform dumping
- `-kdb`: Generate Verdi database
- Uses GCC 4.8 (specified via `-cpp g++-4.8 -cc gcc-4.8`)

### File Paths
Many modules use absolute paths (e.g., `/home/jay/Desktop/graduation_project/`). When modifying code, preserve these paths or update them consistently across all files.

### Current Limitations
- No data memory (load/store instructions incomplete)
- No CSR module implementation visible in main openmips.v (referenced in ex.v but not instantiated)
- Limited instruction ROM size (32 instructions max)

### Verification
- RISC-V test suite is available in `verification/riscv-tests/` but integration is unclear
- Test programs should be placed in `rtl/vsrc/instrom/` as `.s` files
