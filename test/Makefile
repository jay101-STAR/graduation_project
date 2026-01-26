SRCS = $(shell find ./ -name "*.v")
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
	$(VCS)
	./simv -l sim.log

verdi_self_test: comp
	verdi -ssf /home/jay/Desktop/graduation_project/test/tb_driver_ctrl.fsdb




clean:
	rm -rf csrc simv* *.lib *.lib++ nLint*
	rm -rf *.log *.vpd *.key *log *.fsdb
	rm -rf ./vsrc/instrom/*.o ./vsrc/instrom/*.bin 
