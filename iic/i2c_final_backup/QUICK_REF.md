# I2C Master-Slave Quick Reference

## Quick Start

```bash
cd i2c_final
make comp      # Compile and run simulation
make verdi     # View waveforms
make log       # View simulation results
make clean     # Clean up
```

## Test Results Summary

✓ All 6 tests passed successfully!

### Test 1: Single Byte Write
- Wrote 0xAA to address 0x000
- EEPROM confirmed: memory[0]=aa

### Test 2: Single Byte Read
- Read from address 0x000
- Result: 0xAA (matches written data)

### Test 3: Multi-Byte Write
- Wrote 5 bytes (0x10-0x14) to addresses 0x100-0x104
- All bytes confirmed in EEPROM memory

### Test 4: Multi-Byte Read
- Read 5 bytes from addresses 0x100-0x104
- All bytes correct: 0x10, 0x11, 0x12, 0x13, 0x14

### Test 5: High Address Test
- Wrote 0xFF to address 0x7FF (highest address)
- Read back successfully

### Test 6: Overwrite Test
- Overwrote address 0x000 with 0x55
- Read back successfully

## Module Usage Example

### Write Single Byte
```verilog
@(posedge clk);
mem_addr  = 11'h000;      // Address
wr_data   = 8'hAA;        // Data to write
num_bytes = 8'd1;         // Single byte
cmd_rw    = 0;            // Write operation
cmd_valid = 1;            // Start transaction
@(posedge clk);
cmd_valid = 0;
wait (done);              // Wait for completion
```

### Read Single Byte
```verilog
@(posedge clk);
mem_addr  = 11'h000;      // Address
num_bytes = 8'd1;         // Single byte
cmd_rw    = 1;            // Read operation
cmd_valid = 1;            // Start transaction
@(posedge clk);
cmd_valid = 0;
wait (done);              // Wait for completion
// rd_data now contains the read value
```

### Write Multiple Bytes
```verilog
// Write 5 bytes starting from address 0x100
// Data will be: wr_data, wr_data+1, wr_data+2, ...
@(posedge clk);
mem_addr  = 11'h100;      // Starting address
wr_data   = 8'h10;        // First byte value
num_bytes = 8'd5;         // 5 bytes
cmd_rw    = 0;            // Write operation
cmd_valid = 1;
@(posedge clk);
cmd_valid = 0;
wait (done);
```

### Read Multiple Bytes
```verilog
// Read 5 bytes starting from address 0x100
@(posedge clk);
mem_addr  = 11'h100;      // Starting address
num_bytes = 8'd5;         // 5 bytes
cmd_rw    = 1;            // Read operation
cmd_valid = 1;
@(posedge clk);
cmd_valid = 0;
wait (done);
// rd_data contains the last byte read
```

## Signal Descriptions

### Control Signals
- **clk**: System clock (100MHz)
- **rst_n**: Active low reset
- **cmd_valid**: Assert high for one clock cycle to start transaction
- **cmd_rw**: 0=write, 1=read
- **num_bytes**: Number of bytes to transfer (1-255)

### Address and Data
- **mem_addr[10:0]**: 11-bit EEPROM address (0x000-0x7FF)
- **wr_data[7:0]**: Data to write (for multi-byte, auto-increments)
- **rd_data[7:0]**: Data read from EEPROM

### Status Signals
- **busy**: High during transaction
- **done**: Pulses high for one clock when transaction completes

### I2C Bus
- **scl**: I2C clock line (requires pull-up)
- **sda**: I2C data line (requires pull-up, bidirectional)

## Timing

- System clock period: 10ns (100MHz)
- I2C timeslice: 100ns
- Single byte write: ~10μs
- Single byte read: ~15μs
- Inter-transaction delay: 1μs

## Memory Map

```
0x000 - 0x0FF: Device 0 (256 bytes)
0x100 - 0x1FF: Device 1 (256 bytes)
0x200 - 0x2FF: Device 2 (256 bytes)
0x300 - 0x3FF: Device 3 (256 bytes)
0x400 - 0x4FF: Device 4 (256 bytes)
0x500 - 0x5FF: Device 5 (256 bytes)
0x600 - 0x6FF: Device 6 (256 bytes)
0x700 - 0x7FF: Device 7 (256 bytes)
Total: 2048 bytes (2KB)
```

## Common Issues

### Issue: Simulation hangs
**Solution**: Check that pull-up resistors are present on SDA and SCL

### Issue: Read returns 0xFF
**Solution**: Verify write operation completed before reading

### Issue: Compilation errors
**Solution**: Ensure VCS and Verdi are properly installed and in PATH

## File Structure

```
i2c_final/
├── i2c_master.v      # I2C master controller
├── i2c_eeprom.v      # EEPROM slave model
├── i2c_tb.v          # Testbench
├── Makefile          # Build automation
├── README.md         # Full documentation
└── QUICK_REF.md      # This file
```

## Performance

- Simulation time: ~0.2 seconds
- Total test duration: ~216ms (simulated time)
- All 6 tests complete successfully
- Memory usage: <1MB

## Next Steps

1. Integrate with your RISC-V processor
2. Add interrupt support for transaction completion
3. Implement DMA for large data transfers
4. Add error detection and recovery
5. Support for multiple EEPROM devices

## Support

For issues or questions, refer to:
- README.md for detailed documentation
- sim.log for simulation results
- i2c_test.fsdb for waveform analysis
