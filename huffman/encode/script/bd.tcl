
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# huffman

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu7ev-ffvc1156-2-e
   set_property BOARD_PART xilinx.com:zcu104:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:util_vector_logic:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
huffman\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set aclk_0 [ create_bd_port -dir I -type clk aclk_0 ]
  set almost_empty_0 [ create_bd_port -dir O almost_empty_0 ]
  set aresetn_0 [ create_bd_port -dir I -type rst aresetn_0 ]
  set m_axis_tdata_0 [ create_bd_port -dir O -from 127 -to 0 m_axis_tdata_0 ]
  set m_axis_tready_0 [ create_bd_port -dir I m_axis_tready_0 ]
  set m_axis_tvalid_0 [ create_bd_port -dir O m_axis_tvalid_0 ]
  set rd_0 [ create_bd_port -dir I rd_0 ]
  set s_axis_tdata_0 [ create_bd_port -dir I -from 7 -to 0 s_axis_tdata_0 ]
  set s_axis_tdata_1 [ create_bd_port -dir I -from 63 -to 0 s_axis_tdata_1 ]
  set s_axis_tlast_0 [ create_bd_port -dir I s_axis_tlast_0 ]
  set s_axis_tready_0 [ create_bd_port -dir O s_axis_tready_0 ]
  set s_axis_tready_1 [ create_bd_port -dir O s_axis_tready_1 ]
  set s_axis_tvalid_0 [ create_bd_port -dir I s_axis_tvalid_0 ]
  set s_axis_tvalid_1 [ create_bd_port -dir I s_axis_tvalid_1 ]
  set start_0 [ create_bd_port -dir I start_0 ]
  set we_0 [ create_bd_port -dir I we_0 ]

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property CONFIG.HAS_TLAST {1} $axis_data_fifo_0


  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_1 ]
  set_property -dict [list \
    CONFIG.HAS_AEMPTY {1} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_1


  # Create instance: axis_data_fifo_2, and set properties
  set axis_data_fifo_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_2 ]
  set_property CONFIG.TDATA_NUM_BYTES {16} $axis_data_fifo_2


  # Create instance: huffman_0, and set properties
  set block_name huffman
  set block_cell_name huffman_0
  if { [catch {set huffman_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $huffman_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /huffman_0/rst]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_0


  # Create port connections
  connect_bd_net -net aclk_0_1 [get_bd_ports aclk_0] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins axis_data_fifo_2/s_axis_aclk] [get_bd_pins huffman_0/clk]
  connect_bd_net -net aresetn_0_1 [get_bd_ports aresetn_0] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins axis_data_fifo_2/s_axis_aresetn] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net axis_data_fifo_0_m_axis_tdata [get_bd_pins axis_data_fifo_0/m_axis_tdata] [get_bd_pins huffman_0/fifo_i_data]
  connect_bd_net -net axis_data_fifo_0_m_axis_tlast [get_bd_pins axis_data_fifo_0/m_axis_tlast] [get_bd_pins huffman_0/fifo_i_last]
  connect_bd_net -net axis_data_fifo_0_m_axis_tvalid [get_bd_pins axis_data_fifo_0/m_axis_tvalid] [get_bd_pins huffman_0/fifo_i_valid]
  connect_bd_net -net axis_data_fifo_0_s_axis_tready [get_bd_ports s_axis_tready_0] [get_bd_pins axis_data_fifo_0/s_axis_tready]
  connect_bd_net -net axis_data_fifo_1_almost_empty [get_bd_ports almost_empty_0] [get_bd_pins axis_data_fifo_1/almost_empty]
  connect_bd_net -net axis_data_fifo_1_m_axis_tdata [get_bd_pins axis_data_fifo_1/m_axis_tdata] [get_bd_pins huffman_0/enc_fifo_i_data]
  connect_bd_net -net axis_data_fifo_1_m_axis_tvalid [get_bd_pins axis_data_fifo_1/m_axis_tvalid] [get_bd_pins huffman_0/enc_fifo_i_valid]
  connect_bd_net -net axis_data_fifo_1_s_axis_tready [get_bd_ports s_axis_tready_1] [get_bd_pins axis_data_fifo_1/s_axis_tready]
  connect_bd_net -net axis_data_fifo_2_m_axis_tdata [get_bd_ports m_axis_tdata_0] [get_bd_pins axis_data_fifo_2/m_axis_tdata]
  connect_bd_net -net axis_data_fifo_2_m_axis_tvalid [get_bd_ports m_axis_tvalid_0] [get_bd_pins axis_data_fifo_2/m_axis_tvalid]
  connect_bd_net -net axis_data_fifo_2_s_axis_tready [get_bd_pins axis_data_fifo_2/s_axis_tready] [get_bd_pins huffman_0/fifo_o_ready]
  connect_bd_net -net huffman_0_concat_dout [get_bd_pins axis_data_fifo_2/s_axis_tdata] [get_bd_pins huffman_0/concat_dout]
  connect_bd_net -net huffman_0_enc_fifo_i_ready [get_bd_pins axis_data_fifo_1/m_axis_tready] [get_bd_pins huffman_0/enc_fifo_i_ready]
  connect_bd_net -net huffman_0_fifo_i_ready [get_bd_pins axis_data_fifo_0/m_axis_tready] [get_bd_pins huffman_0/fifo_i_ready]
  connect_bd_net -net huffman_0_fifo_o_valid [get_bd_pins axis_data_fifo_2/s_axis_tvalid] [get_bd_pins huffman_0/fifo_o_valid]
  connect_bd_net -net m_axis_tready_0_1 [get_bd_ports m_axis_tready_0] [get_bd_pins axis_data_fifo_2/m_axis_tready]
  connect_bd_net -net rd_0_1 [get_bd_ports rd_0] [get_bd_pins huffman_0/rd]
  connect_bd_net -net s_axis_tdata_0_1 [get_bd_ports s_axis_tdata_0] [get_bd_pins axis_data_fifo_0/s_axis_tdata]
  connect_bd_net -net s_axis_tdata_1_1 [get_bd_ports s_axis_tdata_1] [get_bd_pins axis_data_fifo_1/s_axis_tdata]
  connect_bd_net -net s_axis_tlast_0_1 [get_bd_ports s_axis_tlast_0] [get_bd_pins axis_data_fifo_0/s_axis_tlast]
  connect_bd_net -net s_axis_tvalid_0_1 [get_bd_ports s_axis_tvalid_0] [get_bd_pins axis_data_fifo_0/s_axis_tvalid]
  connect_bd_net -net s_axis_tvalid_1_1 [get_bd_ports s_axis_tvalid_1] [get_bd_pins axis_data_fifo_1/s_axis_tvalid]
  connect_bd_net -net start_0_1 [get_bd_ports start_0] [get_bd_pins huffman_0/start]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins huffman_0/rst] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net we_0_1 [get_bd_ports we_0] [get_bd_pins huffman_0/we]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


