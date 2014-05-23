vlib work
vmap work work

vcom -reportprogress -300 -work work pkg/pkg_param.vhd 
vcom -reportprogress -300 -work work pkg/pkg_ieee_802_11ad_param.vhd 
vcom -reportprogress -300 -work work pkg/pkg_ieee_802_11ad_matrix.vhd 
vcom -reportprogress -300 -work work pkg/pkg_support_global.vhd 
vcom -reportprogress -300 -work work pkg/pkg_param_derived.vhd 
vcom -reportprogress -300 -work work pkg/pkg_types.vhd 
vcom -reportprogress -300 -work work pkg/pkg_support.vhd 

vcom -reportprogress -300 -work work src/controller.vhd 

vcom -reportprogress -300 -work work testbench/controller_tb.vhd 

