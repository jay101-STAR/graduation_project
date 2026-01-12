verdiDockWidgetDisplay -dock widgetDock_<Signal_List>
simSetSimulator "-vcssv" -exec "/home/jay/Desktop/graduation_project/rtl/simv" \
           -args
debImport "-dbdir" "/home/jay/Desktop/graduation_project/rtl/simv.daidir"
debLoadSimResult /home/jay/Desktop/graduation_project/rtl/testbench.fsdb
wvCreateWindow
srcHBSelect "testbench" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench" -delim "."
srcHBSelect "testbench" -win $_nTrace1
srcHBSelect "testbench.top" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top" -delim "."
srcHBSelect "testbench.top" -win $_nTrace1
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0" -delim "."
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0.registerfile0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.registerfile0" -delim "."
srcHBSelect "testbench.top.openmips0.registerfile0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0.registerfile0.i0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.registerfile0.i0" -delim "."
srcHBSelect "testbench.top.openmips0.registerfile0.i0" -win $_nTrace1
srcSignalViewSelect "testbench.top.openmips0.registerfile0.i0.rf\[31:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "G1" 1 )} 
wvExpandBus -win $_nWave3 {("G1" 1)}
debExit
