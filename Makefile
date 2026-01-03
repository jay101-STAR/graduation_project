SRCS = $(shell find ./vsrc/ -name "*.v")
VCS = vcs -full64 -sverilog -timescale=1ns/1ns \
      		+v2k \
		-fsdb +define+fsdb \
		-cpp g++-4.8 \
		-cc gcc-4.8 \
		-debug_access+r -kdb  \
		-lca\
		-LDFLAGS -Wl,--no-as-needed \
		 $(SRCS)	
comp:
	$(VCS) 
	./simv -l sim.log


verdi: comp
	verdi -ssf /home/jay/Desktop/graduation_project/testbench.fsdb


clean:
	rm -rf csrc simv* *.lib *.lib++ nLint*
	rm -rf *.log *.vpd *.key *log *.fsdb
