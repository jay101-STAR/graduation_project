# Makefile for I2C Interface Simulation
# Uses Synopsys VCS for compilation and Verdi for waveform viewing

# Compiler and flags
VCS = vcs -full64 -sverilog \
      -timescale=1ns/1ps \
      +v2k \
      -debug_acc+all \
      -debug_region+cell+encrypt \
      -kdb \
      -lca \
      -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
      $(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a \
      -load $(VERDI_HOME)/share/PLI/VCS/LINUX64/libnovas.so:FSDBDumpCmd \
      -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed

# Source files
VSRC = i2c_eeprom.v i2c_eeprom_ctrl.v i2c_eeprom_tb.v

# Default target
.PHONY: all
all: comp

# Compile and run simulation
.PHONY: comp
comp:
	$(VCS) $(VSRC) -o simv
	./simv -l sim.log

# Minimal test
.PHONY: test_minimal
test_minimal:
	$(VCS) i2c_eeprom.v i2c_eeprom_ctrl_simple.v i2c_eeprom_tb_minimal.v -o simv_minimal
	./simv_minimal -l sim_minimal.log

# View waveforms with Verdi
.PHONY: verdi
verdi:
	verdi -ssf /home/jay/Desktop/graduation_project/i2c/i2c_eeprom_test.fsdb

# Clean build artifacts
.PHONY: clean
clean:
	rm -rf simv* csrc *.log *.vcd *.fsdb *.key verdiLog novas* *.conf *.rc *.vpd DVEfiles

# Help target
.PHONY: help
help:
	@echo "I2C Interface Makefile Targets:"
	@echo "  make comp   - Compile and run simulation"
	@echo "  make verdi  - Open Verdi waveform viewer"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make help   - Show this help message"
