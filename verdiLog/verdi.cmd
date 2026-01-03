verdiDockWidgetUndock -dock widgetDock_<Message>
simSetSimulator "-vcssv" -exec "/home/jay/Desktop/graduation_project/simv" -args
debImport "-dbdir" "/home/jay/Desktop/graduation_project/simv.daidir"
debLoadSimResult /home/jay/Desktop/graduation_project/testbench.fsdb
wvCreateWindow
verdiDockWidgetHide -dock widgetDock_<Message>
srcHBSelect "testbench" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench" -delim "."
srcHBSelect "testbench" -win $_nTrace1
srcHBSelect "testbench.top" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top" -delim "."
srcHBSelect "testbench.top" -win $_nTrace1
srcHBSelect "testbench.top.instrom0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.instrom0" -delim "."
srcHBSelect "testbench.top.instrom0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0" -delim "."
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pc_id_pc" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pc_id_pc" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pc_id_pc" -line 11 -pos 1 -win $_nTrace1
srcAction -pos 10 9 5 -win $_nTrace1 -name "pc_id_pc" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "dout" -line 12 -pos 1 -win $_nTrace1
srcAction -pos 11 7 2 -win $_nTrace1 -name "dout" -ctrlKey off
nsMsgSelect -range {1 1-1}
nsMsgAction -tab trace -index {1 1}
nsMsgSelect -range {1 1-1}
verdiDockWidgetHide -dock widgetDock_<Message>
srcHBSelect "testbench.top.openmips0.ex0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.ex0" -delim "."
srcHBSelect "testbench.top.openmips0.ex0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0" -delim "."
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcHBSelect "testbench.top.instrom0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.instrom0" -delim "."
srcHBSelect "testbench.top.instrom0" -win $_nTrace1
wvCreateWindow
schCreateWindow -delim "." -win $_nSchema1 -scope "testbench.top.instrom0"
schSelect -win $_nSchema4 -inst "i0"
schPushViewIn -win $_nSchema4
schSelect -win $_nSchema4 -inst "i0"
schPushViewIn -win $_nSchema4
schSelect -win $_nSchema4 -inst \
          "MuxKeyInternalwithdefault\(@11\):Always0:49:58:Combo"
schPushViewIn -win $_nSchema4
srcSetScope -win $_nTrace1 "testbench.top.instrom0.i0.i0" -delim "."
srcSelect -win $_nTrace1 -range {49 58 1 3 1 1}
srcDeselectAll -win $_nTrace1
schCreateWindow -delim "." -win $_nSchema1 -scope "testbench.top.instrom0.i0.i0"
verdiDockWidgetSetCurTab -dock widgetDock_MTB_SOURCE_TAB_1
verdiDockWidgetSetCurTab -dock windowDock_nSchema_4
verdiDockWidgetSetCurTab -dock windowDock_nSchema_5
verdiDockWidgetSetCurTab -dock windowDock_nSchema_4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
schLastView -win $_nSchema4
verdiDockWidgetSetCurTab -dock windowDock_nSchema_5
schSetOptions -win $_nSchema5 -pan on
schSelect -win $_nSchema5 -port "lut\[65:0\]"
schPopViewUp -win $_nSchema5
schSelect -win $_nSchema5 -port "default_out\[31:0\]"
schPopViewUp -win $_nSchema5
schCloseWindow -win $_nSchema5
schCloseWindow -win $_nSchema4
srcHBSelect "testbench.top.instrom0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.instrom0" -delim "."
srcHBSelect "testbench.top.instrom0" -win $_nTrace1
srcHBSelect "testbench.top.instrom0.i0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.instrom0.i0" -delim "."
srcHBSelect "testbench.top.instrom0.i0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0.ex0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.ex0" -delim "."
srcHBSelect "testbench.top.openmips0.ex0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0" -win $_nTrace1
srcHBSelect "testbench.top.openmips0.id0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.id0" -delim "."
srcHBSelect "testbench.top.openmips0.id0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_inst" -line 6 -pos 1 -win $_nTrace1
srcHBSelect "testbench.top.openmips0.ex0.i00" -win $_nTrace1
srcHBSelect "testbench.top.openmips0.id0" -win $_nTrace1
srcSetScope -win $_nTrace1 "testbench.top.openmips0.id0" -delim "."
srcHBSelect "testbench.top.openmips0.id0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_inst" -line 6 -pos 1 -win $_nTrace1
srcHBDrag -win $_nTrace1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvAddSignal -win $_nWave2 "/testbench/top/openmips0/id0/id_inst\[31:0\]"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 212.156806 -snap {("G1" 1)}
wvSetOptions -win $_nWave2 -hierName on
wvSetCursor -win $_nWave2 212.342075 -snap {("G1" 1)}
wvSetOptions -win $_nWave2 -hierName off
wvSetCursor -win $_nWave2 220.432181 -snap {("G1" 1)}
wvSetOptions -win $_nWave2 -hierName on
wvSetOptions -win $_nWave2 -hierName off
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetOptions -win $_nWave2 -hierName on
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetOptions -win $_nWave2 -hierName off
wvSetOptions -win $_nWave2 -hierName on
wvSetOptions -win $_nWave2 -hierName off
wvSetOptions -win $_nWave2 -hierName on
wvSelectGroup -win $_nWave2 {G2}
wvSetOptions -win $_nWave2 -hierName off
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetOptions -win $_nWave2 -hierName on
wvSetCursor -win $_nWave2 197.018001 -snap {("G1" 1)}
wvSetOptions -win $_nWave2 -hierName off
wvSetOptions -win $_nWave2 -hierName on
wvSetOptions -win $_nWave2 -hierName off
wvSetOptions -win $_nWave2 -hierName on
wvSetCursor -win $_nWave2 208.246193 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 215.205816 -snap {("G1" 1)}
wvSetOptions -win $_nWave2 -hierName off
verdiWindowWorkMode -win $_Verdi_1 -hardwareDebug
verdiDockWidgetHide -dock widgetDock_<Message>
verdiWindowWorkMode -win $_Verdi_1 -hardwareDebug
nsMsgAction -tab trace -index {1 1}
nsMsgSelect -range {1 0-0}
nsMsgAction -tab trace -index {1 0}
nsMsgSelect -range {1 0-0}
nsMsgAction -tab trace -index {1 0}
nsMsgSelect -range {0 1-1}
nsMsgAction -tab trace -index {0 1}
nsMsgSelect -range {0 1-1}
nsMsgAction -tab trace -index {0 1}
nsMsgSelect -range {0 0-0}
nsMsgAction -tab trace -index {0 0}
nsMsgSelect -range {0 0-0}
nsMsgSelect -range {0-0}
nsMsgAction -tab trace -index {0}
nsMsgSelect -range {0-0}
nsMsgSelect -range {1-1}
nsMsgAction -tab trace -index {1}
nsMsgSelect -range {1-1}
nsMsgSelect -range {1 1-1}
verdiDockWidgetHide -dock widgetDock_<Message>
debExit
