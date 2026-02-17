SRCS = $(shell find ./ -name "*.v")
VCS = vcs -full64 -sverilog -timescale=1ns/1ns \
      		+v2k \
		 +define+fsdb \
		-debug_acc+dmptf -debug_region+cell+encrypt \
		-cpp g++-4.8 \
		-cc gcc-4.8 \
		-debug_access+r -kdb  \
		-LDFLAGS -Wl,--no-as-needed \
		+lint=TFIPC-L \
		 $(SRCS)	

comp:
	$(VCS)
	./simv -l sim.log

verdi: comp
	verdi -ssf /home/jay/Desktop/graduation_project/rtl/testbench.fsdb

clean:
	rm -rf csrc simv* *.lib *.lib++ nLint*
	rm -rf *.log *.vpd *.key *log *.fsdb
	rm -rf ./vsrc/instrom/*.o ./vsrc/instrom/*.bin 
