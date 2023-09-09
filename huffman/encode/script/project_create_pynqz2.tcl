# @Author: Haha Chen 
# @Date: 2023-09-09 12:02:16 
# @Last Modified by:   Haha Chen 
# @Last Modified time: 2023-09-09 12:02:16 

set device_model xc7z020clg400-1; # 设置芯片型号

set dev_dir [pwd]; # 获取当前目录

cd $dev_dir; # 进入当前目录

# 创建工程
create_project project_1 $dev_dir -part $device_model
# set_param board.repoPaths {C:\Users\ChenHaHa\AppData\Roaming\Xilinx\Vivado\2022.2\xhub\board_store\xilinx_board_store\XilinxBoardStore\Vivado\2022.2\boards\TUL\pynq-z2\A.0\1.0}
# xhub::install [xhub::get_xitems tul.com.tw:pynq-z2:part0:1.0]
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
set_property compxlib.questa_compiled_library_dir C:/questasim64_10.6c/vivado_lib [current_project]
set_property simulator_language Verilog [current_project]

# 添加源文件
# add_files -fileset sim_1 ../tb/tb.v
add_files [glob ../rtl/*.v]

import_files -force -norecurse; # 导入源文件

source ../script/blk_mem_gen_0.tcl; # 添加ip

source ../script/bd.tcl; # 导入bd.tcl脚本

make_wrapper -files [get_files $dev_dir/project_1.srcs/sources_1/bd/design_1/design_1.bd] -top; # 生成wrapper
add_files -norecurse $dev_dir/project_1.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v; # 添加wrapper文件

set_property top design_1_wrapper [current_fileset]; #设置顶层文件

update_compile_order -fileset sources_1