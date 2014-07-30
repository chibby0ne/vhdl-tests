vsim work.check_node_tb
add wave -decimal sim:/*

add wave -decimal sim:/input
add wave -unsigned sim:/dut/data_in_sign
add wave -unsigned sim:/dut/data_in_mag
add wave -unsigned sim:/dut/data_in_sign_i
add wave -unsigned sim:/dut/data_in_mag_i
add wave -unsigned sim:/dut/four_min_s2_out
add wave -unsigned sim:/dut/four_min_s2_out_first_half

add wave -unsigned sim:/dut/count
add wave -unsigned sim:/dut/four_min_s3_out
add wave -unsigned sim:/dut/four_min_s3_out_out_reg
add wave -unsigned sim:/dut/four_min_s3_out_out_mux
add wave -unsigned sim:/dut/data_out_mag

run -all
