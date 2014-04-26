vsim work.ram_tb
add wave -decimal sim:/*
add wave -decimal sim:/dut/myram
run -all

