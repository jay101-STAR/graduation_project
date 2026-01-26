# RISC-V Test Integration Guide

## What I've Done

1. **Expanded Instruction ROM**: Increased from 1024 to 2048 words (8KB) in `vsrc/instrom.v:10`

2. **Created ELF-to-Hex Converter**: `vsrc/instrom/elf2hex.sh` converts RISC-V test ELF files to hex format

3. **Added Makefile Target**: `make test-riscv` runs the rv32ui-p-simple test

4. **Added Test Monitoring**: Modified `vsrc/testbench.v` to monitor the "tohost" address (0x80001000) for test results

## How to Run Tests

```bash
cd rtl

# Run the rv32ui-p-simple test
make test-riscv

# View waveforms
make verdi
```

## Test Result Convention

RISC-V tests use the "tohost" mechanism:
- Address: 0x80001000
- Value = 1: Test PASSED
- Value > 1: Test FAILED (failure code = value >> 1)

## Current Status

The test runs but doesn't complete within 20200ns. This could indicate:

1. **Missing Instructions**: Your CPU may not implement all instructions the test uses
2. **CSR Issues**: The test uses CSR instructions (mcause, etc.) - check if `csr.v` is properly integrated
3. **Memory Access**: The test writes to 0x80001000 but your CPU may not support stores yet
4. **Trap Handling**: The test has trap vectors that may not work correctly

## Debugging Steps

### 1. Check What Instructions Are Used
```bash
grep -E "^\s+[0-9a-f]+:" verification/riscv-tests/isa/rv32ui-p-simple.dump | \
  awk '{print $3}' | sort | uniq
```

### 2. Add Debug Output
Add to `vsrc/testbench.v`:
```verilog
always @(posedge clk) begin
  if (!rst) begin
    $display("PC=%h INST=%h",
      top.openmips0.pc_id_pc,
      top.instrom0.instrom_openmips_data);
  end
end
```

### 3. Check for Infinite Loops
Look in waveforms for PC stuck at same address

### 4. Verify CSR Module
The test uses CSR instructions. Check if `vsrc/csr.v` is instantiated in `vsrc/openmips.v`

## Running Other Tests

To run different tests:
```bash
cd rtl
./vsrc/instrom/elf2hex.sh ../verification/riscv-tests/isa/<test-name> ./vsrc/instrom/instrom.hex
make comp
```

Available tests in `verification/riscv-tests/isa/`:
- rv32ui-p-*: User-level integer instructions
- rv32mi-p-*: Machine-level instructions
- rv32um-p-*: Multiply/divide instructions

## Next Steps

1. Add instruction trace to see what's executing
2. Check if CPU supports store instructions (needed to write tohost)
3. Verify CSR implementation
4. Start with simpler tests that don't use CSRs or traps
