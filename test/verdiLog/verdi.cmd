simSetSimulator "-vcssv" -exec "/home/jay/Desktop/graduation_project/test/simv" \
           -args
debImport "-dbdir" "/home/jay/Desktop/graduation_project/test/simv.daidir"
debLoadSimResult /home/jay/Desktop/graduation_project/test/tb_driver_ctrl.fsdb
wvCreateWindow
srcSignalViewSelect "tb_driver_ctrl.CS_AS"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "tb_driver_ctrl.CS_RW_B"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "tb_driver_ctrl.CS_AD\[15:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "tb_driver_ctrl.mclk"
srcSignalViewAddSelectedToWave -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
debExit
