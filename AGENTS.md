# AGENTS.md - RISC-V Processor Implementation Guide

## Quick Reference

### Build & Test Commands
```bash
cd rtl  # All commands must be run from rtl directory

# Default: compile and simulate with default assembly program
make comp

# Run specific tests
make test-load-store           # Load/store instruction tests
make test-unaligned            # Unaligned memory access
make test-riscv                # Official RISC-V test suite

# Waveform analysis (must run after a test)
make verdi                     # Opens Verdi with testbench.fsdb

# Cleanup
make clean                     # Remove build artifacts
```

### Running Single Assembly Test
```bash
cd rtl/vsrc/instrom
# 1. Edit or create your test.s file
# 2. Run llvm.sh to assemble
./llvm.sh your_test.s          # Generates your_test.hex
# 3. Copy hex file to instrom.hex (if using instrom.v default)
cp your_test.hex instrom.hex
# 4. Compile and simulate
cd ../..
make comp
```

### Assembly Toolchains
- **LLVM** (preferred): `./vsrc/instrom/llvm.sh file.s` - Uses llvm-mc/llvm-objcopy for RV32IM
- **GNU**: `./vsrc/instrom/asm2hex.sh file.s` - Uses riscv32-unknown-elf-as/objcopy

Both generate `.hex` files loaded by `instrom.v` at initialization.

---

## Code Style Guidelines

### Naming Conventions
- **Modules**: lowercase with underscores (e.g., `openmips`, `chj_registerfile`, `dataram`)
- **Signals**: `source_dest_signal` pattern (e.g., `pc_id_pc`, `id_ex_rs1_data`, `ex_reg_rd_wen`)
- **Constants**: ALL_CAPS with underscores (e.g., `R_TYPE`, `ADD_TYPE`, `PC_BASE_ADDR`)
- **Generic Parameters**: UPPERCASE in `#()` syntax (e.g., `.WIDTH(32)`, `.RESET_VAL(32'h8000_0000)`)

### Signal Naming Patterns
- `ren`/`wen`: Read/Write enable signals
- `raddr`/`waddr`: Read/Write address
- `rdata`/`wdata`: Read/Write data
- `_aluc`: 4-bit instruction type category
- `_alucex`: 8-bit specific operation encoding

### File Organization
```
define.v          # All macro definitions, instruction encodings (NO LOGIC)
reg.v             # Generic parameterized register module (reusable)
pc.v              # Program counter
id.v              # Instruction decode
ex.v              # Execute stage
csr.v             # Control and status registers
dataram.v         # Data memory
registerfile.v    # Register file (32 registers)
instrom.v         # Instruction ROM (32 entries, loaded from hex file)
openmips.v        # Top-level processor core (connects all pipeline stages)
top.v             # Top-level wrapper
testbench.v       # Test harness (runs for 2200ns)
```

### Include Paths
- Use **absolute paths** consistently (e.g., `` `include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v" ``)
- Preserve absolute paths when adding new files

### Constants & Macros
- Define all constants in `define.v` using `` `define`` directive
- Constants grouped by category: instruction types, ALU operations, func3/func7 fields
- Use readable hex format with underscores: `32'h8000_0000`
- Define complex operations as macros (e.g., `PACK_ARRAY`, `UNPACK_ARRAY`)

### Module Instantiation
```verilog
module_name instance_name (
    .port_name(connection),
    .port_name(connection)
);

// Parameterized modules
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

### Signal Declaration
- Declare all wires explicitly (avoid implicit wires)
- Use consistent width specification: `[31:0]`, `[4:0]`, `[7:0]`
- Group related signals together with comments
- Use `$signed()` for signed comparisons

### Comment Style
- Mixed English and Chinese comments acceptable
- Section headers: `// Section description`
- Inline comments: `// Explanation of logic`
- Block comments: `/* Multi-line explanation */`

---

## Architecture Notes

### Pipeline Stages (Classic 5-Stage)
1. **IF**: `pc.v` generates addresses, `instrom.v` supplies instructions
2. **ID**: `id.v` decodes instructions, reads register file
3. **EX**: `ex.v` performs ALU operations, branch resolution, CSR operations
4. **MEM**: `dataram.v` (data memory access)
5. **WB**: Register file writeback from EX stage

### PC Base Address
All instructions execute from `0x8000_0000` (RISC-V convention). The PC register and all address calculations use this base.

### Signal Flow
- **Forward**: pc→id→ex→regfile (writeback)
- **Backward**: ex→pc (branches, jumps, traps, mret)
- **Cross-stage**: id→regfile→id (register read)

### Test Completion
Tests write to `tohost` memory-mapped register at `0x80001000`:
- `1`: Test passed
- Other values: Test failed (value >> 1 = error code)
- Testbench monitors `tohost_value` signal from `dataram.v`

---

## Build System

### VCS Compilation Flags
```makefile
vcs -full64 -sverilog -timescale=1ns/1ns \
     +v2k \
     +define+fsdb \
     -debug_acc+dmptf -debug_region+cell+encrypt \
     -cpp g++-4.8 \
     -cc gcc-4.8 \
     -debug_access+r -kdb
```
- Generates Verdi waveform database (`-kdb`)
- Dumps FSDB waveforms by default (see `testbench.v:34-35`)
- Uses GCC 4.8 for compilation

### Simulation Parameters
- Clock: 20ns period (50 MHz)
- Reset: 200ns
- Active simulation: 2000ns
- Total: 2200ns

---

## Testing Strategy

### RISC-V Test Suite
Location: `verification/riscv-tests/isa/`

Test categories:
- `rv32ui-*`: Integer instructions
- `rv32mi-*`: Machine-level tests (CSR, exceptions, misaligned access)

To run specific test:
1. Convert ELF to hex: `elf2hex.sh path/to/test output.hex`
2. Compile and simulate with `make test-riscv`
3. Check `sim.log` for results

### Custom Tests
1. Write assembly in `rtl/vsrc/instrom/your_test.s`
2. Assemble: `./vsrc/instrom/llvm.sh your_test.s`
3. Either:
   - Copy to `instrom.hex` for default loading, OR
   - Modify `instrom.v` line 12 to use your hex file
4. Run `make comp`
5. Examine `sim.log` or waveforms with `make verdi`

---

## Important Constraints

### Type Safety
- Never suppress synthesis warnings
- Explicit wire widths required
- Use `$signed()` for signed arithmetic operations

### Signal Naming
- Follow existing `source_dest_signal` pattern for ALL new signals
- Maintain consistency across all modules

### Module Structure
- Keep each module focused on single stage/function
- Use `define.v` constants, not magic numbers
- Instantiate reusable modules (e.g., `Reg`) instead of duplicating flip-flop logic

### Absolute Paths
- Preserve `/home/jay/Desktop/graduation_project/` in all `` `include`` directives
- Update consistently if project moves

---

## Known Limitations

- **No data memory for load/store tests**: Tests in `dataram.v` are incomplete
- **Instruction ROM limited to 32 entries**: For longer programs, extend `instrom.v`
- **Forwarding unit not implemented**: May need data hazard handling for multi-cycle operations

---

## Quick Debugging Checklist

1. **Compilation failed**: Check `csrc/` directory for generated C wrapper, verify syntax errors
2. **Simulation failed**: Check `sim.log` for runtime errors, X propagation
3. **Test stuck**: Check `tohost_value` signal, verify test writes completion value
4. **Waveform analysis**: Use `make verdi` to inspect `testbench.fsdb`, check:
   - PC progression
   - Instruction decode (check `id_ex_alucex` signal)
   - Branch condition calculation
   - Register file writeback

---

## External References

- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- [RISC-V Test Suite](https://github.com/riscv/riscv-tests)
- VCS Documentation: Use `-help` flag
- Verdi Documentation: Waveform viewer for debugging
