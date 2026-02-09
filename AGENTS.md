# AGENTS.md - RISC-V Processor Implementation Guide

## Project Overview

This is a RISC-V processor (graduation project) implemented in Verilog. The design implements a subset of the RV32I instruction set with some RV32M (multiply/divide) support and Zicsr (CSR) extensions. The processor uses a **single-cycle architecture** where each instruction completes in one clock cycle.

### Key Directories
- `rtl/` - Main RISC-V processor implementation
  - `vsrc/` - Verilog source files
  - `csrc/` - C source files for simulation
  - `test_results/` - Test output logs
- `verification/` - Test suites and verification infrastructure
- `spike/` - RISC-V ISA simulator reference
- `iic/` - I2C interface implementation (related project)
- `practise/` - Practice exercises and testbenches

## Quick Reference

### Build & Test Commands (run from `rtl/` directory)
```bash
make comp                           # Compile & simulate with default assembly
make test-load-store                # Load/store instruction tests
make test-unaligned                 # Unaligned memory access
make test-riscv                     # Official RISC-V test suite
make verdi                          # View waveforms (after test run)
make clean                          # Remove build artifacts
```

### Running Custom Assembly Test
```bash
cd rtl/vsrc/instrom
./llvm.sh your_test.s              # Assemble to hex (uses llvm-mc/objcopy)
cp your_test.hex instrom.hex        # Set as active test
cd ../..
make comp                          # Compile and simulate
```

### Test Scripts (run from `rtl/` directory)
```bash
./run_single_test.sh rv32ui-p-add  # Run single RISC-V test
./quick_test.sh                    # Run all RV32UI tests
./run_tests.sh                     # Comprehensive test suite
./prepare_test.sh <test_name>      # Prepare test for simulation
./debug_test.sh                    # Debug test with waveform
```

---

## Code Style Guidelines

### Naming Conventions
- **Modules**: lowercase with underscores (`openmips`, `registerfile`, `dataram`)
- **Signals**: `source_dest_signal` pattern (`pc_id_pc`, `id_ex_rs1_data`, `ex_reg_rd_wen`)
- **Constants**: ALL_CAPS with underscores (`R_TYPE`, `ADD_TYPE`, `PC_BASE_ADDR`)
- **Parameters**: UPPERCASE in `#()` syntax (`.WIDTH(32)`, `.RESET_VAL(32'h8000_0000)`)

### Signal Naming Patterns
- `ren`/`wen`: Read/Write enable
- `raddr`/`waddr`: Read/Write address
- `rdata`/`wdata`: Read/Write data
- `_aluc`: 4-bit instruction type category
- `_alucex`: 8-bit specific operation encoding

### File Organization
```
define.v          # All macros/constants (NO LOGIC)
reg.v             # Generic parameterized register
pc.v              # Program counter
id.v              # Instruction decode
ex.v              # Execute stage (ALU, branch, CSR)
csr.v             # Control/status registers
dataram.v         # Data memory
registerfile.v    # 32x32 general-purpose registers
instrom.v         # Instruction ROM (loads .hex)
openmips.v        # Top-level processor core
top.v             # Wrapper
testbench.v       # Test harness (2200ns simulation)
```

### Include Paths & Constants
- Use **absolute paths**: `` `include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v" ``
- Define all constants in `define.v` using `` `define``
- Group by category: instruction types, ALU ops, func3/func7
- Use readable hex format: `32'h8000_0000`
- Declare all wires explicitly, use consistent width spec: `[31:0]`, `[4:0]`
- Use `$signed()` for signed comparisons

### Module Instantiation
```verilog
Reg #(
    .WIDTH(32),
    .RESET_VAL(32'h8000_0000)
) instance_name (
    .clk(clk),
    .rst(rst),
    .din(input_signal),
    .dout(output_signal)
);
```

---

## Architecture Notes

### 5-Stage Pipeline
1. **IF**: `pc.v` + `instrom.v` (fetch)
2. **ID**: `id.v` (decode, register read)
3. **EX**: `ex.v` (ALU, branch, CSR)
4. **MEM**: `dataram.v` (memory access)
5. **WB**: Register writeback

### Signal Flow
- Forward: pc→id→ex→regfile
- Backward: ex→pc (branches, jumps, mret)
- Cross-stage: id→regfile→id (register read)

### PC & Test Completion
- Base address: `0x8000_0000` (RISC-V convention)
- Tests write to `tohost` register at `0x80001000`: `1` = pass

---

## Build System

### VCS Compilation
```makefile
vcs -full64 -sverilog -timescale=1ns/1ns \
     +v2k +define+fsdb \
     -debug_acc+dmptf -debug_region+cell+encrypt \
     -cpp g++-4.8 -cc gcc-4.8 -debug_access+r -kdb
```
- Generates Verdi waveform database (`-kdb`)
- Dumps FSDB waveforms (see `testbench.v:34-35`)

### Simulation Parameters
- Clock: 20ns (50 MHz)
- Reset: 200ns
- Active simulation: 2000ns

### Prerequisites
- Synopsys VCS (with GCC 4.8)
- Verdi waveform viewer
- RISC-V toolchain: `riscv32-unknown-elf-as`, `riscv32-unknown-elf-objcopy`
- LLVM toolchain: `llvm-mc`, `llvm-objcopy` (for RV32IM support)

---

## Testing Strategy

### RISC-V Test Suite
Location: `verification/riscv-tests/isa/`
- `rv32ui-*`: Integer instructions
- `rv32mi-*`: Machine-level (CSR, exceptions, misaligned)

To run: `elf2hex.sh path/to/test output.hex` → `make test-riscv`

### Custom Tests
Write assembly in `rtl/vsrc/instrom/`, assemble with `llvm.sh`, run `make comp`

### Test Script Usage
```bash
# Single test
./run_single_test.sh rv32ui-p-add

# Batch testing
./quick_test.sh "rv32ui-p-*"

# Prepare test for manual simulation
./prepare_test.sh ../verification/riscv-tests/isa/rv32ui-p-lb
```

---

## Agent-Specific Guidelines

### For AI Coding Agents (Claude, Cursor, Copilot)
1. **Always verify signal naming** follows `source_dest_signal` pattern
2. **Use absolute include paths** as shown in existing files
3. **Check `define.v` first** before adding new constants
4. **Follow module instantiation patterns** from existing code
5. **Run `make comp` after changes** to verify compilation
6. **Test with `./quick_test.sh`** for regression testing

### Code Modification Protocol
1. Read existing similar modules for patterns
2. Check `define.v` for available constants
3. Use parameterized modules (`Reg`, `mux`) when possible
4. Verify signal widths match RISC-V specification
5. Run simulation test after changes

### Error Handling
- **Never** suppress synthesis warnings or use `as any`
- Fix all compilation errors before proceeding
- Verify test results match expected behavior
- Check waveform (`make verdi`) for timing issues

---

## Important Constraints

- **Never** suppress synthesis warnings or use `as any`
- Follow `source_dest_signal` pattern for ALL new signals
- Use `define.v` constants, not magic numbers
- Instantiate reusable modules (e.g., `Reg`) instead of duplicating logic
- Maintain absolute paths in all `` `include`` directives
- All test code must write to `tohost` register for pass/fail indication

---

## Known Limitations

- Data memory for load/store tests incomplete in `dataram.v`
- Instruction ROM limited to 32 entries (extend `instrom.v` for longer programs)
- Data hazard forwarding unit not fully implemented
- FENCE, FENCE.I instructions not implemented
- ECALL, EBREAK may be partially implemented

---

## Quick Debugging Checklist

1. **Compilation failed**: Check `csrc/` for generated C wrapper, verify syntax
2. **Simulation failed**: Check `sim.log` for runtime errors, X propagation
3. **Test stuck**: Check `tohost_value` signal, verify test writes completion
4. **Waveform analysis**: `make verdi` → check PC, `id_ex_alucex`, branch condition, reg writeback
5. **Test failure**: Check test assembly, verify instruction encoding matches RISC-V spec

### Common Issues
- **X propagation**: Uninitialized registers or missing resets
- **Wrong PC value**: Check branch/jump logic in `ex.v`
- **Memory access errors**: Verify `dataram.v` address decoding
- **CSR issues**: Check `csr.v` register definitions and access permissions

---

## External References

- [RISC-V ISA Spec](https://riscv.org/technical/specifications/)
- [RISC-V Test Suite](https://github.com/riscv/riscv-tests)
- [Verilog Style Guide](https://inst.eecs.berkeley.edu/~cs150/fa06/Labs/verilog-rtl.pdf)
- [VCS User Guide](https://www.synopsys.com/content/dam/synopsys/verification/PDF/vcs_user_guide.pdf)

---

## Project-Specific Notes

### Instruction Set Support
**RV32I Base Integer Instructions (fully supported):**
- Arithmetic: ADD, SUB, ADDI
- Logical: AND, OR, XOR, ANDI, ORI, XORI
- Shifts: SLL, SRL, SRA, SLLI, SRLI, SRAI
- Comparisons: SLT, SLTU, SLTI, SLTIU
- Branches: BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jumps: JAL, JALR
- Upper immediates: LUI, AUIPC
- Loads: LB, LH, LW, LBU, LHU (with unaligned access support)
- Stores: SB, SH, SW (with unaligned access support)

**RV32M Multiply/Divide Extension (partial support):**
- Check implementation status in `ex.v`

**Zicsr Extension (supported):**
- CSR instructions: CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
- Exception handling: MRET
- CSR registers: mtvec, mepc, mcause, mstatus