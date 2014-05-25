vsim work.controller_tb
add wave -unsigned sim:/*
add wave -position 4 sim:/controller_tb/dut/pr_state
add wave -position 4 sim:/controller_tb/dut/index_row_sig
add wave -position 4 sim:/controller_tb/dut/cng_counter_sig
add wave -position 4 sim:/controller_tb/dut/vector_addr_sig
add wave -position 4 sim:/controller_tb/dut/start_pos_next_half_sig
run -all
