# Unaligned Memory Access Test Guide

## Overview

This guide explains how to run the unaligned memory access tests for S_TYPE (store) and L_TYPE (load) instructions.

## Test Files

1. **unaligned_test_comprehensive.s** - Full test suite with 17 test cases
2. **unaligned_test_quick.s** - Quick verification with 7 test cases
3. **unaligned_test_expected_output.txt** - Detailed expected output

## Running the Tests

### Option 1: Run Comprehensive Test

```bash
cd rtl/vsrc/instrom

# 1. Assemble the test program
./llvm.sh unaligned_test_comprehensive.s

# 2. Copy the hex file to instrom.hex (or modify instrom.v to use your hex)
cp unaligned_test_comprehensive.hex instrom.hex

# 3. Compile and simulate
cd ../..
make comp

# 4. Check simulation results
cat sim.log

# 5. View waveforms (optional)
make verdi
```

### Option 2: Run Quick Test

```bash
cd rtl/vsrc/instrom

# 1. Assemble the test program
./llvm.sh unaligned_test_quick.s

# 2. Copy the hex file to instrom.hex
cp unaligned_test_quick.hex instrom.hex

# 3. Compile and simulate
cd ../..
make comp

# 4. Check simulation results
cat sim.log
```

## Expected Results

### Success Criteria

- **tohost register** (address 0x80001000) = **0x1**
- **Simulation time**: Test completes within 2200ns
- **No simulation errors**: Check sim.log for any runtime errors

### Failure Indicators

- **tohost register** ≠ 0x1
  - tohost = (error_count << 1) indicates how many tests failed
- **Simulation hangs**: PC stuck at some address
- **Runtime errors**: X propagation, assertion failures, etc.

## Test Coverage

### Comprehensive Test (unaligned_test_comprehensive.s)

| Test Suite | Tests | Description |
|------------|-------|-------------|
| Word Unaligned | 4 | LW/SW at offsets 1, 2, 3 |
| Halfword Unaligned | 5 | SH/LH/LHU at odd offsets |
| Byte Access | 2 | SB/LB/LBU sign/zero extension |
| Overlapping Writes | 3 | Unaligned writes overlapping aligned data |
| Mixed Size | 2 | Store as one size, read as another |
| Byte Offsets | 4 | Word access at all 4 byte offsets |

**Total**: 20 test cases

### Quick Test (unaligned_test_quick.s)

| Test | Description | Expected Result |
|------|-------------|-----------------|
| 1 | Word read at offset 1 | x3 = 0x44000000 |
| 2 | Word read at offset 2 | x5 = 0x77880000 |
| 3 | Word read at offset 3 | x6 = 0x00000000 |
| 4 | Halfword at offset 1 (signed) | x8 = 0xFFFFFE00 |
| 5 | Halfword at offset 1 (unsigned) | x9 = 0x0000FE00 |
| 6 | Byte sign extension | x11 = 0xFFFFFFFF |
| 7 | Overlapping unaligned write | x14 = 0x11222222 |

**Total**: 7 test cases

## Debugging

### Check Test Progress

In the waveform (Verdi), monitor:
- **x10** - Test progress counter (incremented before each test)
- **x11** - Error counter (incremented on test failure)

### Check Memory Access

Monitor these signals in `ex.v`:
- **ex_mem_wen** - Memory write enable
- **ex_mem_ren** - Memory read enable
- **ex_mem_addr** - Memory address (check for alignment)
- **ex_mem_wdata** - Data to write
- **ex_mem_rdata** - Data read from memory

### Common Issues

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| Test hangs at unaligned access | Alignment check blocking access | Verify `ex_mem_addr[1:0]` correctly handled |
| Incorrect data read | Byte order or byte selection wrong | Check little-endian byte ordering |
| Overlapping test fails | Unaligned write not updating correct bytes | Verify byte enable signals |
| Sign extension wrong | Sign extension logic incorrect | Check sign extension for LH/LB |

## Verification with RISC-V Test Suite

After passing custom tests, verify with official RISC-V tests:

```bash
cd rtl/vsrc/instrom

# Convert RISC-V test ELF to hex
./elf2hex.sh path/to/rv32ui-p-add output.hex

# Copy hex file
cp output.hex instrom.hex

# Run simulation
cd ../..
make test-riscv
```

Run these unaligned access tests from RISC-V test suite:
- `rv32mi-p-ma_fetch` - Misaligned instruction fetch
- `rv32mi-p-ma_load` - Misaligned load
- `rv32mi-p-ma_store` - Misaligned store

## Expected Memory Layout

See `unaligned_test_expected_output.txt` for detailed memory layout after each test.

### Key Memory Regions

| Address Range | Size | Usage |
|---------------|------|-------|
| 0x80000000 - 0x80000013 | 20 bytes | Word unaligned tests |
| 0x80000010 - 0x80000023 | 20 bytes | Halfword unaligned tests |
| 0x80000028 - 0x80000033 | 12 bytes | Overlapping write tests |
| 0x80000032 - 0x8000003b | 10 bytes | Mixed size tests |
| 0x80000050 - 0x8000005f | 16 bytes | Byte offset tests |

## Interpretation of Results

### Pass
```
$ cat sim.log
...
Time: 2000ns
PC: 0x8000xxxx
tohost_value: 1
Test PASSED
```

### Fail
```
$ cat sim.log
...
Time: 2000ns
PC: 0x8000xxxx
tohost_value: 2  (error code = 2 << 1 = 4)
Test FAILED: 2 tests failed
```

### Simulation Error
```
$ cat sim.log
...
Error: Assertion failed in ex.v:123
Error: X propagation detected at time 1500ns
```

Check waveforms at the reported time to diagnose the issue.

## Next Steps

1. **All tests pass**: Implementation is correct, proceed to integration testing
2. **Some tests fail**: Debug using waveform analysis
3. **Simulation errors**: Check for syntax errors or logic bugs

## Additional Resources

- RISC-V ISA Specification: https://riscv.org/technical/specifications/
- RISC-V Test Suite: https://github.com/riscv/riscv-tests
- AGENTS.md: Build and test commands reference
