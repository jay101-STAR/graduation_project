# Unaligned Memory Access Implementation

## Overview
This implementation adds support for unaligned load and store instructions to the RISC-V processor. The processor can now handle memory accesses that are not aligned to word (4-byte), halfword (2-byte), or byte boundaries.

## Changes Made

### 1. Fixed Load Address Calculation (ex.v:52)
**Problem**: Load instructions were not calculating the effective address correctly. The address should be `rs1 + immediate`, but only `rs1` was being used.

**Solution**: Modified the address calculation to add the immediate value for load instructions:
```verilog
assign ex_dataram_addr = (id_ex_aluc == `L_TYPE) ? (id_ex_rs1_data + id_ex_rs2_data) : id_ex_rs1_data;
```

### 2. Unaligned Load Support (dataram.v:19-34)
**Implementation**:
- Read from two consecutive words when data might span word boundaries
- Combine the 64-bit data and shift based on byte offset
- Extract the required data size (byte, halfword, or word)

**Key changes**:
```verilog
wire [12:0] word_addr_next = word_addr + 1;
wire [63:0] combined_data = {mem_data_next, mem_data};
wire [63:0] shifted_data = combined_data >> (byte_offset * 8);
wire [31:0] word_unaligned = shifted_data[31:0];
wire [15:0] halfword_unaligned = shifted_data[15:0];
```

### 3. Unaligned Store Support (dataram.v:36-80)
**Implementation**:
- For each store type (SB, SH, SW), handle all possible byte offsets
- When data spans word boundaries, write to both current and next word
- Preserve existing data in unaffected byte positions

**Examples**:
- **SW at offset 1**: Writes 24 bits to current word [31:8], 8 bits to next word [7:0]
- **SH at offset 3**: Writes 8 bits to current word [31:24], 8 bits to next word [7:0]
- **SW at offset 2**: Writes 16 bits to current word [31:16], 16 bits to next word [15:0]

## Test Results

The test program (`unaligned_test.s`) verifies:
1. ✅ Aligned word store/load (offset 0)
2. ✅ Unaligned word store/load (offset 1)
3. ✅ Unaligned halfword store/load (offset 3)
4. ✅ Unaligned word store/load (offset 2)
5. ✅ Unaligned word store/load (offset 3)
6. ✅ Byte loads from various offsets
7. ✅ Byte stores at unaligned positions
8. ✅ Word load after byte stores

**Test Status**: ✅ PASSED

## How to Run Tests

```bash
cd rtl

# Run the unaligned access test
make test-unaligned

# View waveforms
make verdi
```

## Technical Details

### Memory Layout
- Base address: 0x80000000
- Memory size: 32KB (8192 words)
- Word-addressable with byte offset handling

### Supported Instructions
- **Load**: LB, LH, LW, LBU, LHU (all with unaligned support)
- **Store**: SB, SH, SW (all with unaligned support)

### Performance Considerations
- Unaligned accesses complete in the same cycle as aligned accesses
- No performance penalty for unaligned access in this implementation
- Hardware handles all alignment automatically

## Example: Unaligned Word Store at Offset 1

```
Address:     0x80000000  0x80000004
Before:      [AA BB CC DD] [11 22 33 44]
Store 0x12345678 at 0x80000001:
After:       [AA 78 56 34] [12 22 33 44]
             └─ preserved  └─ preserved
                └──────┬──────┘
                  stored data
```

## Compliance
This implementation follows the RISC-V specification for unaligned memory access, allowing software to access memory at any byte address without alignment restrictions.
