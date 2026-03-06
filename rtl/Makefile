# 使用原来的 dataram.v
SRCS =  $(shell find ./vsrc/ -name "*.v")
SPLIT_INST = python3 ./vsrc/dataram/mem_image_tool.py init-instrom --instrom ./vsrc/instrom/instrom.hex --out-dir ./vsrc/dataram
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

.PHONY: clean
comp:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/bp_tests/bp_tntn.s
	cp ./vsrc/instrom/bp_tests/bp_tntn.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv -l sim.log

simv_build:
	$(VCS)

run_simv:
	./simv -l sim.log

test-benchmark:
	cp ../verification/riscv-tests/benchmarks/rv32im_build/output/multiply.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv -l sim.log

test-uart-rx-smoke:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/uart_rx_smoke_test.s
	cp ./vsrc/instrom/uart_rx_smoke_test.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv +uart_rx_smoke -l sim.log

test-uart-rx-double:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/uart_rx_double_read_test.s
	cp ./vsrc/instrom/uart_rx_double_read_test.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv +uart_rx_smoke -l sim.log

test-uart-rx-overrun:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/uart_rx_overrun_test.s
	cp ./vsrc/instrom/uart_rx_overrun_test.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv +uart_rx_overrun_smoke -l sim.log

test-uart-tx-smoke:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/uart_tx_smoke_test.s
	cp ./vsrc/instrom/uart_tx_smoke_test.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv +uart_tx_smoke -l sim.log

test-uart-tx-back-to-back:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/uart_tx_back_to_back_test.s
	cp ./vsrc/instrom/uart_tx_back_to_back_test.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv +uart_tx_smoke -l sim.log

test-uart-loopback-echo:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/uart_loopback_echo_test.s
	cp ./vsrc/instrom/uart_loopback_echo_test.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
	$(VCS)
	./simv +uart_loopback_smoke -l sim.log

prep-uart-echo-forever:
	./vsrc/instrom/llvm.sh ./vsrc/instrom/uart_echo_forever.s
	cp ./vsrc/instrom/uart_echo_forever.hex ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)

test-riscv:
	./prepare_test.sh ../verification/riscv-tests/isa/rv32ui-p-lb
	./vsrc/instrom/elf2hex.sh ../verification/riscv-tests/isa/rv32ui-p-lb ./vsrc/instrom/instrom.hex
	$(SPLIT_INST)
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
	rm -rf csrc simv simv.daidir DVEfiles verdiLog stack.info.*
	rm -f vc_hdrs.h ucli.key
	rm -f *.vpd *.fsdb *.key *.lib *.lib++ nLint* novas.conf novas.rc novas_dump.log AN.DB
	rm -rf test_results
	rm -f ./vsrc/instrom/*.o ./vsrc/instrom/*.bin ./vsrc/instrom/*.dump
	rm -f ./vsrc/instrom/test_temp.hex ./vsrc/instrom/test_temp.hex.bin
	rm -f ./vsrc/instrom/perf_temp.hex ./vsrc/instrom/perf_temp.hex.bin
	rm -f ./vsrc/instrom/*.backup ./vsrc/instrom/*.hex.*_backup
	rm -f ./vsrc/dataram/*.backup ./vsrc/dataram/*.hex.*_backup
