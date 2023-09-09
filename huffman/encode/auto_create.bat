@REM @Author: Haha Chen 
@REM @Date: 2023-09-09 12:01:50 
@REM @Last Modified by:   Haha Chen 
@REM @Last Modified time: 2023-09-09 12:01:50 

set cache_floder=project_1.cache
set project_dir=%~dp0FPGA

if exist %project_dir% ( 
    echo The floder is exist.
    pause
) else (
    mkdir %project_dir%
    cd %project_dir%
    vivado -source ../script/project_create_pynqz2.tcl
)
exit