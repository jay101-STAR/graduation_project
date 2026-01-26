simSetSimulator "-vcssv" -exec "/home/jay/Desktop/graduation_project/i2c/simv" \
           -args
debImport "-dbdir" "/home/jay/Desktop/graduation_project/i2c/simv.daidir"
debLoadSimResult /home/jay/Desktop/graduation_project/i2c/i2c_eeprom_test.fsdb
wvCreateWindow
srcHBSelect "i2c_eeprom_tb.ctrl" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_eeprom_tb.ctrl" -delim "."
srcHBSelect "i2c_eeprom_tb.ctrl" -win $_nTrace1
srcHBSelect "i2c_eeprom_tb.eeprom_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_eeprom_tb.eeprom_inst" -delim "."
srcHBSelect "i2c_eeprom_tb.eeprom_inst" -win $_nTrace1
srcHBSelect "i2c_eeprom_tb.ctrl" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_eeprom_tb.ctrl" -delim "."
srcHBSelect "i2c_eeprom_tb.ctrl" -win $_nTrace1
srcHBSelect "i2c_eeprom_tb.eeprom_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_eeprom_tb.eeprom_inst" -delim "."
srcHBSelect "i2c_eeprom_tb.eeprom_inst" -win $_nTrace1
srcHBSelect "i2c_eeprom_tb.ctrl" -win $_nTrace1
srcSetScope -win $_nTrace1 "i2c_eeprom_tb.ctrl" -delim "."
srcHBSelect "i2c_eeprom_tb.ctrl" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 12 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/i2c_eeprom_tb/ctrl/rd_data\[7:0\]"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
debExit
