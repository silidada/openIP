# @Author: Haha Chen 
# @Date: 2023-09-09 12:02:50 
# @Last Modified by:   Haha Chen 
# @Last Modified time: 2023-09-09 12:02:50 

import os
import time
import shutil

# ---------------------------------------------------- the parameters you need to change ----------------------------------------------------

# 测试的顶层文件
tb_name = "tb_top.sv"

# 运行时间
run_time = "500ns"

# 需要添加的波形
wave_list = ["*", "uut/design_1_i/huffman_0/inst/ctrl_inst/*"]


# 是否启动 questasim 的gui界面
without_gui = False

# 需要添加的ip lib
lib_list = ["blk_mem_gen_v8_4_2"]

# 需要添加的命令
insert_command = r"vlog -64 -incr -work work ..\\FPGA\\project_1.gen\\sources_1\\ip\\blk_mem_gen_0\\sim/blk_mem_gen_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v D:/Users/ChenHaHa/Documents/MyOwn/project/huffman/FPGA/project_2/project_2.gen/sources_1/bd/design_1/synth/design_1.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_axis_data_fifo_0_0/sim/design_1_axis_data_fifo_0_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_axis_data_fifo_1_0/sim/design_1_axis_data_fifo_1_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_axis_data_fifo_2_0/sim/design_1_axis_data_fifo_2_0.v \
    ../FPGA/project_1.gen/sources_1/bd/design_1/ip/design_1_util_vector_logic_0_0/sim/design_1_util_vector_logic_0_0.v"

# -------------------------------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------- the system parameters ----------------------------------------------------

# tb文件目录
tb_dir = "./tb"

# rtl文件目录
src_dir = "./rtl"

# questasim或者modelsim的路径
# questasim_path = r"C:\questasim64_10.6c\win64\vsim"
questasim_path = "vsim"

# -------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------- advanced ----------------------------------------------------

# 是否使用do文件
do_file = True

# ------------------------------------------------------------------------------------------------------------------






insert_lib = ""
for lib in lib_list:
    insert_lib += "-L {} ".format(lib)

insert_wave = ""

for wave in wave_list:
    if wave == "":
        insert_wave += "add wave -divider divider\n"
    elif wave.startswith("divider:") or wave.startswith("d:"):
        insert_wave += "add wave -divider {}\n".format(wave.split(":")[1])
    else:
        insert_wave += "add wave -position end  sim:/{}/{}\n".format(tb_name.split(".")[0], wave)


def write_makefile(src_dir, tb_dir, tb_name):
    f = open("Makefile", "w")
    f.write("all: create_lib compile simulate\n")
    f.write("""
create_lib:
	vlib work
compile:
	vlog -l compile.log -sv {}/*.v {}/{}.sv
simulate:
	vsim -l sim.log -c -novopt -do "run -all" tb_id
clean:
	rm -rf work
    """.format(src_dir, tb_dir, tb_name.split(".")[0]))    
    f.close()


def write_do(rtl_dir, tb_dir, tb_name):
    lib_dir = r"C:/questasim64_10.6c/vivado_lib"
    f = open("sim.do", "w")
    f.write("""
# delete the old lib first
if [file exists "work"] {{vdel -all}}

# new lib
vlib work
vlib msim
vlib msim/xil_defaultlib

# base library
vmap xil_defaultlib msim/xil_defaultlib
vmap secureip {}/secureip
vmap unimacro {}/unimacro
vmap unisim {}/unisim
vmap unifast {}/unifast

{}

vlog {}/*.v {}/{}.sv glbl.v -l compile.log

vsim -c -voptargs=+acc {} work.{} -l sim.log

# add wave
{}

# run
run {}
{}
    """.format(lib_dir, lib_dir, lib_dir, lib_dir, insert_command, rtl_dir, tb_dir, tb_name.split(".")[0], insert_lib, tb_name.split(".")[0], insert_wave, run_time, "quit -force" if without_gui else ""))


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def read_log(name):
    f = open(name+".log", "r")
    lines = f.readlines()
    f.close()
    print(bcolors.HEADER, "="*50, name, " info " + "="*50, bcolors.ENDC)
    
    for line in lines[:-1]:
        if "Error" in line:
            print(bcolors.FAIL + line + bcolors.ENDC)
        elif "Warning" in line:
            print(bcolors.WARNING + line + bcolors.ENDC)
    print(bcolors.OKBLUE, lines[-1], bcolors.ENDC)


if __name__ == "__main__":
    os.system("cls")
    # os.popen("cd ./sim")
    os.popen(r"copy C:\Xilinx\Vivado\2018.3\data\verilog\src\glbl.v glbl.v")


    # write_tb(tb_dir, tb_name, include)
    if do_file:
        write_do(src_dir, tb_dir, tb_name)
        # start simulation
        os.system('{} -do "sim.do"'.format(questasim_path + (" -c " if without_gui else "")))
    else:
        write_makefile(src_dir, tb_dir, tb_name)
        # start simulation
        os.system('{} -do "make"'.format(questasim_path + " -c " if without_gui else ""))
    

    read_log("compile")
    read_log("sim")

    if do_file:
        os.remove("sim.do")
    else:
        os.remove("Makefile")

    os.remove("compile.log")
    os.remove("sim.log")
    os.remove("transcript")
    os.remove("glbl.v")
    # shutil.rmtree("./sim/work")



