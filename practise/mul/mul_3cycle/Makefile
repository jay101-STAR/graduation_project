# ============================================================================
# Makefile for 3-Cycle Multiplier Testing
# ============================================================================

# Compiler settings
SIMV = ./simv
VCS = vcs -full64 -sverilog -timescale=1ns/1ns \
      +v2k \
      +define+fsdb \
      -debug_acc+dmptf -debug_region+cell+encrypt \
      -cpp g++-4.8 \
      -cc gcc-4.8 \
      -debug_access+r -kdb  \
      -lca \
      -LDFLAGS -Wl,--no-as-needed \
      +lint=TFIPC-L

# Source files
RTL_SRC = mul_3cycle.v booth.v 4compress.v 32yasuo.v
TB_SRC = tb_mul_3cycle.v

# Output files
SIMV_BIN = simv
VCD_FILE = tb_mul_3cycle.vcd
LOG_FILE = test.log

# ============================================================================
# Targets
# ============================================================================

.PHONY: all compile run clean help wave

# Default target
all: compile run

# Compile the design and testbench
compile:
	@echo "============================================================"
	@echo "编译3周期乘法器和测试平台..."
	@echo "============================================================"
	$(VCS) $(RTL_SRC) $(TB_SRC) -o $(SIMV_BIN)
	@echo "编译完成!"
	@echo ""

# Run simulation
run:
	@echo "============================================================"
	@echo "运行仿真..."
	@echo "============================================================"
	$(SIMV) -l $(LOG_FILE)
	@echo ""
	@echo "仿真完成! 查看 $(LOG_FILE) 了解详情."
	@echo ""

# Compile and run in one step
test: compile run

# View waveform with GTKWave (if available)
wave:
	@if [ -f $(VCD_FILE) ]; then \
		echo "打开波形查看器..."; \
		gtkwave $(VCD_FILE) &; \
	else \
		echo "错误: $(VCD_FILE) 未找到. 请先运行仿真."; \
	fi

# Clean generated files
clean:
	@echo "清理生成的文件..."
	rm -rf $(SIMV_BIN) $(SIMV_BIN).daidir csrc ucli.key
	rm -f $(VCD_FILE) $(LOG_FILE)
	rm -f *.vpd *.vcd *.log
	@echo "清理完成!"

# Show help
help:
	@echo "============================================================"
	@echo "3周期乘法器测试 Makefile"
	@echo "============================================================"
	@echo "可用命令:"
	@echo "  make all      - 编译并运行仿真 (默认)"
	@echo "  make compile  - 仅编译"
	@echo "  make run      - 仅运行仿真"
	@echo "  make test     - 编译并运行 (同 all)"
	@echo "  make wave     - 打开波形查看器 (GTKWave)"
	@echo "  make clean    - 清理生成的文件"
	@echo "  make help     - 显示此帮助信息"
	@echo "============================================================"
