SRCS = $(shell find ./vsrc/ -name "*.v")
VCS = vcs -full64 -sverilog -timescale=1ns/1ns \
      		+v2k \
		 +define+fsdb \
		-debug_acc+dmptf -debug_region+cell+encrypt \
		-cpp g++-4.8 \
		-cc gcc-4.8 \
		-debug_access+r -kdb  \
		-lca\
		-LDFLAGS -Wl,--no-as-needed \
		 $(SRCS)	
comp:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/instrom.s
	$(VCS)
	./simv -l sim.log

test-load-store:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/load_store_test.s
	$(VCS)
	./simv -l sim.log

test-unaligned:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/unaligned_test.s
	cp ./vsrc/instrom/unaligned_test.hex ./vsrc/instrom/instrom.hex
	$(VCS)
	./simv -l sim.log

test-unaligned-comprehensive:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/comprehensive_unaligned_test.s
	cp ./vsrc/instrom/comprehensive_unaligned_test.hex ./vsrc/instrom/instrom.hex
	$(VCS)
	./simv -l sim.log


test-riscv:
	./vsrc/instrom/elf2hex.sh ../verification/riscv-tests/isa/rv32ui-p-ld_st ./vsrc/instrom/instrom.hex
	$(VCS)
	./simv -l sim.log

verdi_self_test: comp
	verdi -ssf /home/jay/Desktop/graduation_project/rtl/testbench.fsdb

verdi_official_test: test-riscv
	verdi -ssf /home/jay/Desktop/graduation_project/rtl/testbench.fsdb



clean:
	rm -rf csrc simv* *.lib *.lib++ nLint*
	rm -rf *.log *.vpd *.key *log *.fsdb
	rm -rf ./vsrc/instrom/*.o ./vsrc/instrom/*.bin 
