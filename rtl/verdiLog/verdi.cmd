simSetSimulator "-vcssv" -exec "/home/jay/Desktop/graduation_project/rtl/simv" \
           -args
debImport "-dbdir" "/home/jay/Desktop/graduation_project/rtl/simv.daidir"
debLoadSimResult /home/jay/Desktop/graduation_project/rtl/testbench.fsdb
wvCreateWindow
verdiDockWidgetSetCurTab -dock widgetDock_<Local>
verdiDockWidgetSetCurTab -dock widgetDock_<Member>
srcHBSelect "mux.i0" -win $_nTrace1
srcSetScope -win $_nTrace1 "mux.i0" -delim "."
srcHBSelect "mux.i0" -win $_nTrace1
srcHBSelect "testbench" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench" -delim "."
srcHBSelect "testbench" -win $_nTrace1
srcHBSelect "testbench.top" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top" -delim "."
srcHBSelect "testbench.top" -win $_nTrace1
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0" -delim "."
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0.id0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.id0" -delim "."
srcHBSelect "testbench.top.openmips0.id0" -win $_nTrace1
srcSignalView -on
srcHBSelect "testbench.top.openmips0.registerfile0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.registerfile0" -delim "."
srcHBSelect "testbench.top.openmips0.registerfile0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0.registerfile0.i0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.registerfile0.i0" -delim "."
srcHBSelect "testbench.top.openmips0.registerfile0.i0" -win $_nTrace1
srcSignalViewSelect "testbench.top.openmips0.registerfile0.i0.rf\[31:0\]"
wvAddSignal -win $_nWave3 "/testbench/top/openmips0/registerfile0/i0/rf\[31:0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSelectSignal -win $_nWave3 {( "G1" 1 )} 
wvExpandBus -win $_nWave3 {("G1" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 384.306177 -snap {("G1" 28)}
debExit
