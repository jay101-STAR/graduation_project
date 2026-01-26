# ModelSim Simulation Script for I2C Interface
# Save this file as run_sim.do

# Create work library
vlib work

# Compile all Verilog files
vlog i2c_master.v
vlog i2c_slave.v
vlog i2c_tb.v

# Start simulation
vsim -voptargs=+acc work.i2c_tb

# Add waves to waveform viewer
add wave -position insertpoint sim:/i2c_tb/*
add wave -position insertpoint sim:/i2c_tb/master/*
add wave -position insertpoint sim:/i2c_tb/slave/*

# Configure wave display
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# Run simulation
run -all

# Zoom to fit
wave zoom full
