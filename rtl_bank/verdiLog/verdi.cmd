verdiDockWidgetDisplay -dock widgetDock_<Signal_List>
simSetSimulator "-vcssv" -exec "/home/jay/Desktop/graduation_project/rtl/simv" \
           -args
debImport "-dbdir" "/home/jay/Desktop/graduation_project/rtl/simv.daidir"
debLoadSimResult /home/jay/Desktop/graduation_project/rtl/testbench.fsdb
wvCreateWindow
srcSignalViewSelect "std_bram.addr\[12:0\]"
srcSetScope -win $_nTrace1 "std_bram" -delim "."
srcSetScope -win $_nTrace1 "testbench" -delim "."
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
srcHBSelect "testbench.top.openmips0.registerfile0.i0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.registerfile0.i0" -delim "."
srcHBSelect "testbench.top.openmips0.registerfile0.i0" -win $_nTrace1
srcSignalViewSelect "testbench.top.openmips0.registerfile0.i0.rf\[31:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "G1" 1 )} 
wvExpandBus -win $_nWave3 {("G1" 1)}
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvSetCursor -win $_nWave3 394.047903 -snap {("G1" 30)}
wvScrollDown -win $_nWave3 2
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
srcHBSelect "testbench.top.openmips0.ex0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.ex0" -delim "."
srcHBSelect "testbench.top.openmips0.ex0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "ex_pc_pc_wen" -line 47 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 31)}
wvSetPosition -win $_nWave3 {("G1" 32)}
wvSetPosition -win $_nWave3 {("G1" 33)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvAddSignal -win $_nWave3 "/testbench/top/openmips0/ex0/ex_pc_pc_wen"
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G2" 1)}
wvSetPosition -win $_nWave3 {("G2" 1)}
wvZoomIn -win $_nWave3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
srcSignalViewSelect "testbench.top.openmips0.ex0.op1\[31:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "testbench.top.openmips0.ex0.op2\[31:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G1" 30 )} 
nMemCreateWindow
debExit
