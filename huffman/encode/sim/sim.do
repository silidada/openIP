
# delete the old lib first
if [file exists "work"] {vdel -all}

# new lib
vlib work
vlib msim
vlib msim/xil_defaultlib

# base library
vmap xil_defaultlib msim/xil_defaultlib
vmap secureip C:/questasim64_10.6c/vivado_lib/secureip
vmap unimacro C:/questasim64_10.6c/vivado_lib/unimacro
vmap unisim C:/questasim64_10.6c/vivado_lib/unisim
vmap unifast C:/questasim64_10.6c/vivado_lib/unifast

vlog -64 -incr -work work ..\\FPGA\\project_1.gen\\sources_1\\ip\\blk_mem_gen_0\\sim/blk_mem_gen_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v D:/Users/ChenHaHa/Documents/MyOwn/project/huffman/FPGA/project_2/project_2.gen/sources_1/bd/design_1/synth/design_1.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_axis_data_fifo_0_0/sim/design_1_axis_data_fifo_0_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_axis_data_fifo_1_0/sim/design_1_axis_data_fifo_1_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_axis_data_fifo_2_0/sim/design_1_axis_data_fifo_2_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_util_vector_logic_0_0/sim/design_1_util_vector_logic_0_0.v

vlog ./rtl/*.v ./tb/tb_top.sv glbl.v -l compile.log

vsim -c -voptargs=+acc -L blk_mem_gen_v8_4_2  work.tb_top -l sim.log

# add wave
add wave -position end  sim:/tb_top/*
add wave -position end  sim:/tb_top/uut/design_1_i/huffman_0/inst/ctrl_inst/*


# run
run 500ns

    