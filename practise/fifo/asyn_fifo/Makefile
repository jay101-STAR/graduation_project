SRCS = $(shell find ./ -name "*.v")
VCS = vcs -full64 -sverilog -timescale=1ns/1ns \
			+v2k\
			+define+fsdb \
			-debug_acc+dmptf -debug_region+cell+encrypt \
			-cpp g++-4.8 \
		  -cc gcc-4.8 \
			-debug_access+r -kdb \
			-lca \
			-LDFLAGS -Wl,--no-as-needed \
			$(SRCS)
comp:
	$(VCS)
	./simv -l sim.log

verdi:comp
	verdi -ssf /home/jay/Desktop/graduation_project/practise/fifo/asyn_fifo/testbench.fsdb
