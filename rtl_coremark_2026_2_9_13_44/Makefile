# 使用原来的 dataram.v
SRCS =  $(shell find ./vsrc/ -name "*.v")
VCS = vcs -full64 -sverilog -timescale=1ns/1ns \
      		+v2k \
		 +define+fsdb \
		-debug_acc+dmptf -debug_region+cell+encrypt \
		-cpp g++-4.8 \
		-cc gcc-4.8 \
		-debug_access+r -kdb  \
		-lca\
		-LDFLAGS -Wl,--no-as-needed \
		+lint=TFIPC-L \
		 $(SRCS)	
comp:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/instrom.s
	$(VCS)
	./simv -l sim.log

simv_build:
	$(VCS)

run_simv:
	./simv -l sim.log

test-benchmark:
	cp ../verification/riscv-tests/benchmarks/rv32im_build/output/multiply.hex ./vsrc/instrom/instrom.hex
	$(VCS)
	./simv -l sim.log

test-mul:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/mul_test.s
	cp ./vsrc/instrom/mul_test.hex ./vsrc/instrom/instrom.hex
	$(VCS)
	./simv -l sim.log

test-div:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/div_test.s
	cp ./vsrc/instrom/div_test.hex ./vsrc/instrom/instrom.hex
	$(VCS)
	./simv -l sim.log

test-riscv:
	./prepare_test.sh ../verification/riscv-tests/isa/rv32ui-p-lw
	./vsrc/instrom/elf2hex.sh ../verification/riscv-tests/isa/rv32ui-p-lw ./vsrc/instrom/instrom.hex
	$(VCS)
	./simv -l sim.log

coremark:
	./run_coremark.sh

verdi:
	verdi -ssf /home/jay/Desktop/graduation_project/rtl/testbench.fsdb


verdi_self_test: comp
	verdi -ssf /home/jay/Desktop/graduation_project/rtl/testbench.fsdb

verdi_benchmark: test-benchmark
	verdi -ssf /home/jay/Desktop/graduation_project/rtl/testbench.fsdb

verdi_official_test: test-riscv
	verdi -ssf /home/jay/Desktop/graduation_project/rtl/testbench.fsdb



clean:
	rm -rf csrc simv* *.lib *.lib++ nLint*
	rm -rf *.log *.vpd *.key *log *.fsdb
	rm -rf ./vsrc/instrom/*.o ./vsrc/instrom/*.bin 
