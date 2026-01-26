# Makefile for I2C Master-Slave Simulation
# Uses Synopsys VCS for compilation and Verdi for waveform viewing

# Compiler and simulator
VCS = vcs
VERDI = verdi

# Compiler flags
VCS_FLAGS = -full64 \
            -debug_acc+dmptf \
            -debug_region+cell+encrypt \
            -kdb \
            -lca \
            -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
            $(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a \
            -cpp g++-4.8 \
            -cc gcc-4.8 \
            -LDFLAGS -Wl,--no-as-needed \
            +v2k \
            -sverilog \
            -timescale=1ns/1ps

# Source files
SOURCES = i2c_master.v \
          i2c_eeprom.v \
          i2c_tb.v

# Output files
SIM_EXEC = simv
LOG_FILE = sim.log
FSDB_FILE = i2c_test.fsdb

# Default target
all: comp

# Compile and run simulation
comp: $(SOURCES)
	@echo "========================================="
	@echo "Compiling I2C Master-Slave Design..."
	@echo "========================================="
	$(VCS) $(VCS_FLAGS) $(SOURCES) -o $(SIM_EXEC)
	@echo ""
	@echo "========================================="
	@echo "Running Simulation..."
	@echo "========================================="
	./$(SIM_EXEC) -l $(LOG_FILE)
	@echo ""
	@echo "========================================="
	@echo "Simulation Complete!"
	@echo "Log file: $(LOG_FILE)"
	@echo "Waveform: $(FSDB_FILE)"
	@echo "========================================="

# Compile only (no simulation)
compile: $(SOURCES)
	@echo "Compiling I2C Master-Slave Design..."
	$(VCS) $(VCS_FLAGS) $(SOURCES) -o $(SIM_EXEC)
	@echo "Compilation complete!"

# Run simulation only (assumes already compiled)
run:
	@echo "Running Simulation..."
	./$(SIM_EXEC) -l $(LOG_FILE)
	@echo "Simulation complete! Check $(LOG_FILE) for results."

# View waveforms with Verdi
verdi:
	verdi -ssf i2c_test.fsdb

# View simulation log
log:
	@if [ -f $(LOG_FILE) ]; then \
		cat $(LOG_FILE); \
	else \
		echo "Error: $(LOG_FILE) not found. Run 'make comp' first."; \
	fi

# Clean all generated files
clean:
	@echo "Cleaning up..."
	rm -rf $(SIM_EXEC) $(SIM_EXEC).daidir csrc *.log *.fsdb *.vpd
	rm -rf DVEfiles inter.vpd ucli.key
	rm -rf verdiLog novas* *.conf *.rc
	@echo "Clean complete!"

# Clean everything including waveforms
distclean: clean
	rm -rf *.fsdb *.vcd
	@echo "Deep clean complete!"

# Help target
help:
	@echo "========================================="
	@echo "I2C Master-Slave Makefile Help"
	@echo "========================================="
	@echo "Available targets:"
	@echo "  make all      - Compile and run simulation (default)"
	@echo "  make comp     - Compile and run simulation"
	@echo "  make compile  - Compile only (no simulation)"
	@echo "  make run      - Run simulation (must compile first)"
	@echo "  make verdi    - Open Verdi waveform viewer"
	@echo "  make log      - Display simulation log"
	@echo "  make clean    - Remove generated files"
	@echo "  make distclean- Remove all generated files including waveforms"
	@echo "  make help     - Show this help message"
	@echo "========================================="

.PHONY: all comp compile run verdi log clean distclean help
