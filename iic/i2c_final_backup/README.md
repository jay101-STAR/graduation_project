# I2C Master-Slave Communication System

This directory contains a complete I2C master-slave communication system for EEPROM operations.

## Files

- **i2c_master.v** - I2C master controller module
- **i2c_eeprom.v** - I2C EEPROM slave module (2KB memory)
- **i2c_tb.v** - Comprehensive testbench
- **Makefile** - Build and simulation automation
- **README.md** - This file

## Features

### I2C Master (i2c_master.v)
- Supports single-byte and multi-byte read/write operations
- Compatible with standard I2C protocol timing
- Automatic address increment for multi-byte operations
- Simple task-based implementation for easy understanding
- Configurable timeslice (100ns default)

### EEPROM Slave (i2c_eeprom.v)
- 2048 bytes (2KB) of memory storage
- 11-bit addressing (addresses 0x000 to 0x7FF)
- Supports standard I2C device addresses (0xA0-0xAF)
- Single-byte read/write operations
- Automatic ACK/NACK generation

### Testbench (i2c_tb.v)
The testbench includes 6 comprehensive tests:
1. Single byte write
2. Single byte read
3. Multi-byte write (5 bytes)
4. Multi-byte read (5 bytes)
5. Different address regions (high address test)
6. Overwrite test

## Usage

### Compile and Run Simulation
```bash
make comp
```
This command will:
1. Compile all Verilog source files using VCS
2. Run the simulation
3. Generate waveform file (i2c_test.fsdb)
4. Display test results in sim.log

### View Waveforms
```bash
make verdi
```
Opens Verdi waveform viewer to inspect the I2C signals.

### View Simulation Log
```bash
make log
```
Displays the simulation log file.

### Clean Build Artifacts
```bash
make clean
```
Removes all generated files except source code.

### Help
```bash
make help
```
Shows all available make targets.

## Test Results

All tests pass successfully:
- ✓ Single byte write/read
- ✓ Multi-byte write/read (5 bytes)
- ✓ High address region access (0x7FF)
- ✓ Overwrite operations

Example output:
```
========================================
=== I2C Master-Slave Test Started ===
========================================

--- Test 1: Single Byte Write ---
Writing 0xAA to address 0x000
eeprm---memory[0]=aa
Write completed

--- Test 2: Single Byte Read ---
Reading from address 0x000
Read data = 0xaa
✓ SUCCESS: Read data matches written data

... (all tests pass)

========================================
=== All Tests Completed ===
========================================
```

## I2C Protocol Details

### Write Operation
1. START condition
2. Send device address + W (0xA0-0xAE)
3. Wait for ACK
4. Send memory address (8 bits)
5. Wait for ACK
6. Send data byte
7. Wait for ACK
8. STOP condition

### Read Operation
1. START condition
2. Send device address + W (0xA0-0xAE)
3. Wait for ACK
4. Send memory address (8 bits)
5. Wait for ACK
6. Repeated START condition
7. Send device address + R (0xA1-0xAF)
8. Wait for ACK
9. Read data byte
10. Send NACK
11. STOP condition

### Multi-Byte Operations
For multi-byte operations, the master performs multiple single-byte transactions with automatic address increment. Each byte requires a complete START-STOP sequence.

## Timing Parameters

- System clock: 100 MHz (10ns period)
- I2C timeslice: 100ns
- I2C clock frequency: ~100 kHz
- Inter-transaction delay: 1000ns

## Address Mapping

The EEPROM uses 11-bit addressing:
- Device address bits: addr[10:8] (3 bits)
- Memory address bits: addr[7:0] (8 bits)
- Total addressable memory: 2048 bytes (0x000 to 0x7FF)

## Module Interfaces

### i2c_master
```verilog
module i2c_master (
    input  wire        clk,        // System clock (100MHz)
    input  wire        rst_n,      // Active low reset
    input  wire [10:0] mem_addr,   // EEPROM memory address
    input  wire [ 7:0] wr_data,    // Data to write
    input  wire [ 7:0] num_bytes,  // Number of bytes to read/write
    input  wire        cmd_valid,  // Command valid signal
    input  wire        cmd_rw,     // 0=write, 1=read
    output reg  [ 7:0] rd_data,    // Read data output
    output reg         busy,       // Busy flag
    output reg         done,       // Done flag
    inout  wire        sda,        // I2C data line
    output reg         scl         // I2C clock line
);
```

### eeprom
```verilog
module eeprom (
    input scl,  // I2C clock
    inout sda   // I2C data
);
```

## Notes

- The I2C master uses fork-join_none for non-blocking operation
- Pull-up resistors are required on SDA and SCL lines (provided in testbench)
- The EEPROM slave automatically handles START/STOP condition detection
- Memory contents are initialized to 0 on reset

## Requirements

- Synopsys VCS (tested with O-2018.09-SP2)
- Synopsys Verdi (for waveform viewing)
- GCC 4.8 (for VCS compilation)

## Author

Created for graduation project - RISC-V processor with I2C interface
