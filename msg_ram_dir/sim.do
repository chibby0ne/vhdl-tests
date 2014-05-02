vsim work.msg_ram_tb
add wave -decimal sim:/*
add wave -decimal sim:/dut/ram/myram
run -all

