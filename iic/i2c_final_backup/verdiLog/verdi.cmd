simSetSimulator "-vcssv" -exec \
           "/home/jay/Desktop/graduation_project/i2c_final_backup/simv" -args
debImport "-dbdir" \
          "/home/jay/Desktop/graduation_project/i2c_final_backup/simv.daidir"
debLoadSimResult \
           /home/jay/Desktop/graduation_project/i2c_final_backup/i2c_test.fsdb
wvCreateWindow
srcHBSelect "i2c_tb.eeprom_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.eeprom_inst" -delim "."
srcHBSelect "i2c_tb.eeprom_inst" -win $_nTrace1
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.master" -delim "."
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "scl" -line 18 -pos 1 -win $_nTrace1
srcAction -pos 17 5 2 -win $_nTrace1 -name "scl" -ctrlKey off
srcHBSelect "i2c_tb.eeprom_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.eeprom_inst" -delim "."
srcHBSelect "i2c_tb.eeprom_inst" -win $_nTrace1
srcHBSelect "i2c_tb.master.i2c_read_byte" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.master.i2c_read_byte" -delim "."
srcHBSelect "i2c_tb.master.i2c_read_byte" -win $_nTrace1
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.master" -delim "."
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "scl" -line 18 -pos 1 -win $_nTrace1
srcAction -pos 17 5 1 -win $_nTrace1 -name "scl" -ctrlKey off
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_tb.master" -delim "."
srcHBSelect "i2c_tb.master" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "scl" -line 18 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/i2c_tb/master/scl"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "sda" -line 17 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 "/i2c_tb/master/sda"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 14 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 "/i2c_tb/master/rd_data\[7:0\]"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "cmd_valid" -line 12 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cmd_rw" -line 13 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 "/i2c_tb/master/cmd_rw"
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSelectGroup -win $_nWave2 {G2}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 2)}
nMemCreateWindow
nMemGetVariable -win $_nMem0 -var i2c_tb.eeprom_inst.memory -delim . -from \
           DUMPED_BY_SIMULATOR -addrRange {[2047:0]} -wordBitRange {[7:0]} \
           -wordsInOneRow 8
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
srcDeselectAll -win $_nTrace1
srcSelect -signal "mem_addr" -line 9 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_data" -line 10 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 "/i2c_tb/master/wr_data\[7:0\]"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
nMemCloseWindow -win $_nMem0
verdiHideWindow -win $_nMem0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
nMemCreateWindow
nMemGetVariable -win $_nMem1 -var i2c_tb.eeprom_inst.memory -delim . -from \
           DUMPED_BY_SIMULATOR -addrRange {[2047:0]} -wordBitRange {[7:0]} \
           -wordsInOneRow 8
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemCloseWindow -win $_nMem1
verdiHideWindow -win $_nMem1
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 14 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 "/i2c_tb/master/rd_data\[7:0\]"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
debExit
