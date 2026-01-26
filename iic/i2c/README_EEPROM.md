# I2C EEPROM Controller Implementation

This directory contains an I2C master controller specifically designed to interface with the I2C EEPROM model.

## Files

- **i2c_eeprom.v** - Standard I2C EEPROM slave model (2048 bytes, 11-bit addressing)
- **i2c_eeprom_ctrl_simple.v** - I2C master controller for EEPROM operations
- **i2c_eeprom_tb.v** - Comprehensive testbench with multiple read/write tests
- **i2c_eeprom_tb_minimal.v** - Minimal testbench for quick testing
- **Makefile** - Build and simulation commands

## Controller Features

The `i2c_eeprom_ctrl_simple` module provides:

- **Write Operation**: Sends device address + memory address + data in a single I2C transaction
- **Read Operation**: Sends device address + memory address, then repeated START + device address (read) + data
- **11-bit Addressing**: Supports full 2048-byte EEPROM address space (A10-A8 in device address, A7-A0 as memory address byte)
- **Simple Interface**:
  - `mem_addr[10:0]` - 11-bit EEPROM address
  - `wr_data[7:0]` - Data to write
  - `cmd_valid` - Start transaction
  - `cmd_rw` - 0=write, 1=read
  - `rd_data[7:0]` - Data read
  - `busy` - Transaction in progress
  - `done` - Transaction complete

## Usage

### Compile and Run Full Test
```bash
cd /home/jay/Desktop/graduation_project/i2c
make comp
```

### Run Minimal Test
```bash
make test_minimal
```

### View Waveforms
```bash
make verdi
```

### Clean Build Artifacts
```bash
make clean
```

## Test Results

All tests pass successfully:

```
=== I2C EEPROM Test Started ===
--- Test 1: Write 0xAA to address 0x000 ---
eeprm---memory[0]=aa
--- Test 2: Read from address 0x000 ---
SUCCESS: Read data matches written data
--- Test 3: Write 0x55 to address 0x055 ---
eeprm---memory[55]=55
--- Test 4: Read from address 0x055 ---
SUCCESS: Read data matches written data
--- Test 5: Write 0xFF to address 0x7FF ---
eeprm---memory[7ff]=ff
--- Test 6: Read from address 0x7FF ---
SUCCESS: Read data matches written data
=== All Tests Completed ===
```

## Implementation Details

### I2C Protocol

**Write Sequence:**
1. START condition
2. Device address (1010 + A10-A8 + W)
3. ACK
4. Memory address (A7-A0)
5. ACK
6. Data byte
7. ACK
8. STOP condition

**Read Sequence:**
1. START condition
2. Device address (1010 + A10-A8 + W)
3. ACK
4. Memory address (A7-A0)
5. ACK
6. Repeated START condition
7. Device address (1010 + A10-A8 + R)
8. ACK
9. Data byte
10. NACK
11. STOP condition

### Timing

- Clock divider: 100 (configurable)
- With 100MHz system clock: I2C clock ≈ 1MHz
- Write transaction: ~61us
- Read transaction: ~82us

## Notes

- The controller uses a simple state machine that advances every 100 clock cycles for proper I2C timing
- The EEPROM model requires proper START/STOP conditions and timing
- Pull-up resistors are required on SDA and SCL lines (implemented in testbench)
