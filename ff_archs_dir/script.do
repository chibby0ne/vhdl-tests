vlib work
vmap work work
vcom -reportprogress 300 -work work *.vhd
vsim work.ff_archs_tb
add wave sim:/*
run 
run
run

