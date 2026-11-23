# Active RTL and unified test entry point
SRCS =  $(shell find ./vsrc/ -type f \( -name "*.v" -o -name "*.sv" \))
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

.PHONY: clean comp simv_build run_simv test-add test-uart-sw test-benchmark \
        test-uart-rx-smoke test-uart-rx-double test-uart-rx-overrun \
        test-uart-tx-smoke test-uart-tx-back-to-back test-uart-loopback-echo \
        prep-uart-echo-forever test-riscv coremark verdi verdi_self_test \
        verdi_benchmark verdi_official_test
comp:
	./run.sh prepare ./vsrc/instrom/bp_tests/bp_tntn.s
	$(VCS)
	./simv -l sim.log

test-add:
	./run.sh prepare ./vsrc/instrom/instrom.s
	$(VCS)
	./simv -l sim.log

test-uart-sw:
	./run.sh prepare ./vsrc/instrom/uart_sw_test.s
	$(VCS)
	./simv +uart_tx_smoke +uart_tx_print -l sim.log

simv_build:
	$(VCS)

run_simv:
	./simv -l sim.log

test-benchmark:
	./run.sh benchmark multiply --build

test-uart-rx-smoke:
	./run.sh uart --test uart_rx_smoke --build

test-uart-rx-double:
	./run.sh uart --test uart_rx_double --build

test-uart-rx-overrun:
	./run.sh uart --test uart_rx_overrun --build

test-uart-tx-smoke:
	./run.sh uart --test uart_tx_smoke --build

test-uart-tx-back-to-back:
	./run.sh uart --test uart_tx_back_to_back --build

test-uart-loopback-echo:
	./run.sh uart --test uart_loopback_echo --build

prep-uart-echo-forever:
	./run.sh prepare ./vsrc/instrom/uart_echo_forever.s

test-riscv:
	./run.sh single rv32ui-p-sw --build

coremark:
	./run.sh coremark


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

.PHONY: test-axi4
test-axi4:
	python3 tests/run_axi4.py --cache-mode 10
