simSetSimulator "-vcssv" -exec \
           "/home/jay/Desktop/graduation_project/i2c_interface/simv" -args
debImport "-dbdir" \
          "/home/jay/Desktop/graduation_project/i2c_interface/simv.daidir"
debLoadSimResult /home/jay/Desktop/graduation_project/i2c_interface/i2c_test.fsdb
wvCreateWindow
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.master" -delim "."
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcSignalViewSelect "i2c_tb.master.state\[3:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "i2c_tb.master.shift_reg\[7:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
srcSignalViewSelect "i2c_tb.master.next_state\[3:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
schCreateWindow -hierFSM -win $_nSchema1 -mode all
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 92269349.323435
srcHBSelect "i2c_tb.slave" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.slave" -delim "."
srcHBSelect "i2c_tb.slave" -win $_nTrace1
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.master" -delim "."
srcHBSelect "i2c_tb.master" -win $_nTrace1
debExit
