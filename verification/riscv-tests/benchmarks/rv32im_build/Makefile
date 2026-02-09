# Makefile for compiling benchmarks for RV32IM CPU (graduation project)
# No RVC (compressed instructions), no FPU

# Toolchain
RISCV_PREFIX ?= riscv32-unknown-elf-
CC = $(RISCV_PREFIX)gcc
AS = $(RISCV_PREFIX)as
OBJDUMP = $(RISCV_PREFIX)objdump
OBJCOPY = $(RISCV_PREFIX)objcopy
SIZE = $(RISCV_PREFIX)size

# Compiler flags for RV32IM (NO compressed instructions, NO FPU)
MARCH = rv32im
MABI = ilp32
ASFLAGS = -march=$(MARCH) -mabi=$(MABI)
CFLAGS = -march=$(MARCH) -mabi=$(MABI) -O2 \
         -static -nostdlib -nostartfiles \
         -fno-common -fno-builtin-printf \
         -fno-tree-loop-distribute-patterns \
         -DPREALLOCATE=1 -Wno-implicit-function-declaration

# Directories
BENCH_DIR = ..
BUILD_DIR = .
OUT_DIR = ./output

# Include paths (use our util, not common/util.h)
INCLUDES = -I$(BUILD_DIR)

# Linker script
LDSCRIPT = $(BUILD_DIR)/link_rv32im.ld
LDFLAGS = -T $(LDSCRIPT) -nostdlib -lgcc

# Available benchmarks (that don't need FPU)
BENCHMARKS = multiply median towers vvadd

# Default target
all: dirs $(addprefix $(OUT_DIR)/, $(addsuffix .riscv, $(BENCHMARKS)))

dirs:
	@mkdir -p $(OUT_DIR)

# Assemble startup code
$(OUT_DIR)/crt_rv32im.o: $(BUILD_DIR)/crt_rv32im.S
	@echo "Assembling startup code..."
	$(AS) $(ASFLAGS) $< -o $@

# Compile syscalls
$(OUT_DIR)/syscalls_rv32im.o: $(BUILD_DIR)/syscalls_rv32im.c
	@echo "Compiling syscalls..."
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Multiply benchmark
$(OUT_DIR)/multiply.riscv: $(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o $(LDSCRIPT)
	@echo "Building multiply..."
	$(CC) $(CFLAGS) $(INCLUDES) -I$(BENCH_DIR)/multiply \
		$(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o \
		$(BENCH_DIR)/multiply/multiply.c $(BENCH_DIR)/multiply/multiply_main.c \
		$(LDFLAGS) -o $@
	$(SIZE) $@
	$(OBJDUMP) -d $@ > $(OUT_DIR)/multiply.dump

# Median benchmark
$(OUT_DIR)/median.riscv: $(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o $(LDSCRIPT)
	@echo "Building median..."
	$(CC) $(CFLAGS) $(INCLUDES) -I$(BENCH_DIR)/median \
		$(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o \
		$(BENCH_DIR)/median/median.c $(BENCH_DIR)/median/median_main.c \
		$(LDFLAGS) -o $@
	$(SIZE) $@
	$(OBJDUMP) -d $@ > $(OUT_DIR)/median.dump

# Towers benchmark
$(OUT_DIR)/towers.riscv: $(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o $(LDSCRIPT)
	@echo "Building towers..."
	$(CC) $(CFLAGS) $(INCLUDES) -I$(BENCH_DIR)/towers \
		$(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o \
		$(BENCH_DIR)/towers/towers_main.c \
		$(LDFLAGS) -o $@
	$(SIZE) $@
	$(OBJDUMP) -d $@ > $(OUT_DIR)/towers.dump

# Vvadd benchmark
$(OUT_DIR)/vvadd.riscv: $(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o $(LDSCRIPT)
	@echo "Building vvadd..."
	$(CC) $(CFLAGS) $(INCLUDES) -I$(BENCH_DIR)/vvadd \
		$(OUT_DIR)/crt_rv32im.o $(OUT_DIR)/syscalls_rv32im.o \
		$(BENCH_DIR)/vvadd/vvadd_main.c \
		$(LDFLAGS) -o $@
	$(SIZE) $@
	$(OBJDUMP) -d $@ > $(OUT_DIR)/vvadd.dump

# Generate hex files
$(OUT_DIR)/%.hex: $(OUT_DIR)/%.riscv
	$(OBJCOPY) -O binary $< $(OUT_DIR)/$*.bin
	od -An -tx4 -w4 -v $(OUT_DIR)/$*.bin | awk '{print $$1}' > $@
	@rm -f $(OUT_DIR)/$*.bin
	@echo "Generated $@"

# Build single benchmark with hex
multiply: dirs $(OUT_DIR)/multiply.riscv $(OUT_DIR)/multiply.hex
median: dirs $(OUT_DIR)/median.riscv $(OUT_DIR)/median.hex
towers: dirs $(OUT_DIR)/towers.riscv $(OUT_DIR)/towers.hex
vvadd: dirs $(OUT_DIR)/vvadd.riscv $(OUT_DIR)/vvadd.hex

# Build all hex files
hex: $(addprefix $(OUT_DIR)/, $(addsuffix .hex, $(BENCHMARKS)))

# Show info about compiled benchmarks
info:
	@echo "Available benchmarks: $(BENCHMARKS)"
	@echo "Output directory: $(OUT_DIR)"
	@echo "Compiler: $(CC)"
	@echo "Architecture: $(MARCH)"
	@echo "ABI: $(MABI)"

clean:
	rm -rf $(OUT_DIR)

.PHONY: all dirs hex clean info $(BENCHMARKS)
