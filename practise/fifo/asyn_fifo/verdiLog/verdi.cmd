verdiDockWidgetDisplay -dock widgetDock_<Signal_List>
simSetSimulator "-vcssv" -exec \
           "/home/jay/Desktop/graduation_project/practise/fifo/asyn_fifo/simv" \
           -args
debImport "-dbdir" \
          "/home/jay/Desktop/graduation_project/practise/fifo/asyn_fifo/simv.daidir"
debLoadSimResult \
           /home/jay/Desktop/graduation_project/practise/fifo/asyn_fifo/testbench.fsdb
wvCreateWindow
debExit
