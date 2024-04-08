##########################################################################################
# Tool: IC Compiler II
# Script: PnR.tcl (template)
# Version: P-2020.03-SP4
# Copyright (C) 2023-2024 Ahmed Abdelazeem, Inc. All rights reserved.
##########################################################################################

##############################################
########### 1. DESIGN SETUP ##################
##############################################

##################################
## Setup variables and settings
##################################

source -echo 01_common_setup.tcl

printvar search_path
printvar NDM_REFERENCE_LIB_DIRS
report_host_options
print_suppressed_messages

##################################
## Create the design library
## Load the netlist, SDC, and UPF
##################################
create_lib -technology $TECH_FILE  -ref_libs $NDM_REFERENCE_LIB_DIRS ${DESIGN_NAME}.dlib

read_verilog -top ${DESIGN_NAME} $VERILOG_NETLIST_FILES

link_block

report_ref_libs

get_blocks $DESIGN_NAME
get_blocks ${DESIGN_NAME}.design
get_blocks ${DESIGN_NAME}.dlib:$DESIGN_NAME
get_blocks ${DESIGN_NAME}.dlib:${DESIGN_NAME}.design

##################################
## RC parasitics, placement site
## and routing layer setup
##################################

read_parasitic_tech  -tlup $TLUPLUS_MAX_FILE -layermap $MAP_FILE -name tlup_max

read_parasitic_tech  -tlup $TLUPLUS_MIN_FILE -layermap $MAP_FILE -name tlup_min

report_lib -parasitic_tech [current_lib]

get_site_defs
set_attribute [get_site_defs unit] symmetry Y
set_attribute [get_site_defs unit] is_default true

set_attribute [get_layers {metal1 metal3 metal5 metal7 metal9}] routing_direction horizontal
set_attribute [get_layers {metal2 metal4 metal6 metal8 metal10}] routing_direction vertical
get_attribute [get_layers metal?] routing_direction

report_ignored_layers

####################################
# Check Design: Pre-Floorplanning
####################################
 check_design -checks dp_pre_floorplan
 
##################################
## Save the block
##################################
rename_block -to_block ${DESIGN_NAME}/init_design
save_block
close_blocks 
##############################################
########### 2. Floorplan #####################
##############################################

open_block  ${DESIGN_NAME}.dlib:${DESIGN_NAME}/init_design
# OR
#open_lib  ${DESIGN_NAME}.dlib
#open_block  ${DESIGN_NAME}/init_design
copy_block -from_block pit_top.dlib:pit_top/init_design -to pit_top.dlib:pit_top/floorplan_design 
## Create Starting Floorplan
############################
##################################
## Load UPF, floorplan, scan-DEF
##################################

#load_upf ${DESIGN_NAME}.upf
#commit_upf

set_parasitic_parameters -late_spec tlup_max -early_spec tlup_min


source $SDC_CONSTRAINTS
source 02_mcmm_setup.tcl

## Create Starting Floorplan
############################
initialize_floorplan -core_utilization 0.25 -flip_first_row true -core_offset {10 10 10 10}

## CONSTRAINTS
##############
## Here, We define more constraints on your design that are related to floorplan stage.
#report_ignored_layers
#remove_ignored_layers -all
#set_ignored_layers -max_routing_layer metal6

## Initial Virtual Flat Placement
#################################
## Use the following command with any of its options to meet a specific target
#    create_placement -floorplan -timing_driven -congestion -buffering_aware_timing_driven 
place_pins -ports [get_ports *]

create_placement -floorplan
legalize_placement
set_block_pin_constraints -self -allowed_layers {M3 M4 M5 M6}

##AH## ## To show design-specific blocks
##AH## gui_set_highlight_options -current_color yellow
##AH## change_selection [get_cells  wishbone_addr_latch_reg_0_

##AH## gui_set_highlight_options -current_color blue
##AH##  change_selection [get_cells   wishbone_addr_latch_reg_2_ 

##AH## gui_set_highlight_options -current_color green
##AH## change_selection [get_cells   */*]

##AH## gui_set_highlight_options -current_color orange
##AH## change_selection [get_cells   egs_mod_value_reg_1_]

## ASSESSMENT
#############
## Analyze Congestion
# report_congestion -rerun_global_router 
route_global -congestion_map_only true -effort high   
# View Congestion map : In GUI,  > Global Route Congestion Map.

## Analyze Timing
# estimate_timing; # Improves accuracy of timing after updated GR.

#report_timing -nosplit; # For Worst Setup violation report
#report_timing -nosplit -delay_type min; # For Worst Hold violation report

#report_constraint -all_violators -nosplit -max_delay; # For all Setup violation report
#report_constraint -all_violators -nosplit -min_delay; # For all Hold violations report

##Based on your assessment, you may need to do any of the following fixes

## FIXES
########
## You can use one or all of the follwoing based on your need.
#   estimate_timing 
#
#   create_bound -name "temp" -coordinate {55 0 270 270} datamem
#   create_bound -name "temp1" -coordinate {0 0 104 270} reg_file
#
#   set_congestion_options -max_util 0.4 -coordinate {x1 y1 x2 y2}; # if cell density is causing congestion.
#
#   create_placement_blockage -name PB -type hard -bbox {x1 y1 x2 y2}
#
#   create_placement -floorplan -congestion_effort high
#
## Then you need to re-run create_placement -floorplan 
#   create_placement -floorplan  -incremental; 
## Note:  use -incremental option if you want to refine the current virtual placement. Don't use it if you want to re-place the design from scratch 

## If there still congestion, change ignored layers, if it is still there, increase floorplan area.

#################################
## Perform timing sanity check	
#################################

report_qor -summary -include setup
set_app_options -list {time.delay_calculation_style zero_interconnect}
report_qor -summary -include setup

set_app_options -list {time.high_fanout_net_pin_capacitance 0pF
                       time.high_fanout_net_threshold 50}
update_timing -full
report_qor -summary -include setup

view report_timing -max_paths 5

####################################
## PG Pin connections
#####################################
create_net -power $NDM_POWER_NET
create_net -ground $NDM_GROUND_NET 

connect_pg_net -net $NDM_POWER_NET [get_pins -hierarchical "*/VDD"]
connect_pg_net -net $NDM_GROUND_NET [get_pins -hierarchical "*/VSS"]

check_mv_design 

### Write floorplan for later re-use in ICC2
write_floorplan -net_types {power ground} \
   -include_physical_status {fixed locked} \
   -read_def_options {-add_def_only_objects all -no_incremental} \
   -force -output ./output/{DESIGN_NAME}.fp/

### Write floorplan for DCG:
write_floorplan -net_types {power ground} \
   -include_physical_status {fixed locked} \
   -format icc \
   -force -output ./output/${DESIGN_NAME}.fp.dc

##################################
## Save the block
##################################

save_block -as pit_top.dlib:pit_top/floorplan.design
save_block
# or:
# save_lib


##################################################
########### 3. POWER NETWORK #####################
##################################################
copy_block -from_block pit_top.dlib:pit_top/floorplan_design.design -to_block power_plan_1
current_block power_plan_1.design
## Defining Logical POWER/GROUND Connections
############################################
set_app_option -name plan.pgroute.auto_connect_pg_net -value true
set_app_option -name plan.pgroute.connect_user_route_shapes -value true
set_app_option -name plan.pgroute.disable_floating_removal -value true
set_app_option -name plan.pgroute.disable_trimming -value true


create_net -power $NDM_POWER_NET
create_net -ground $NDM_GROUND_NET 

connect_pg_net -net $NDM_POWER_NET [get_pins -hierarchical "*/VDD"]
connect_pg_net -net $NDM_GROUND_NET [get_pins -hierarchical "*/VSS"]
check_mv_design

remove_pg_via_master_rules -all
remove_pg_patterns -all
remove_pg_strategies -all
remove_pg_strategy_via_rules -all

################################################################################
#-------------------------------------------------------------------------------
# P G   R I N G   C R E A T I O N
#-------------------------------------------------------------------------------
################################################################################
create_pg_ring_pattern ring_pattern -horizontal_layer metal9 \
    -horizontal_width {5} -horizontal_spacing {0.8} \
    -vertical_layer metal10 -vertical_width {5} \
    -vertical_spacing {0.8} -corner_bridge false
set_pg_strategy core_ring -core -pattern \
    {{pattern: ring_pattern}{nets: {VDD VSS}}{offset: {0.8 0.8}}} \
    -extension {{stop: innermost_ring}}

compile_pg -strategies core_ring
################################################################################
#-------------------------------------------------------------------------------
# P G   M E S H   C R E A T I O N
#-------------------------------------------------------------------------------
################################################################################

create_pg_mesh_pattern pg_mesh1 \
   -parameters {w1 p1 w2 p2 f t} \
   -layers {{{vertical_layer: metal10} {width: @w1} {spacing: interleaving} \
        {pitch: @p1} {offset: @f} {trim: @t}} \
 	     {{horizontal_layer: metal9 } {width: @w2} {spacing: interleaving} \
        {pitch: @p2} {offset: @f} {trim: @t}}}


set_pg_strategy s_mesh1 \
   -pattern {{pattern: pg_mesh1} {nets: {VDD VSS VSS VDD}} \
{offset_start: 5 5} {parameters: 5 80 5 120 5 false}} \
   -core -extension {{stop: outermost_ring}}


compile_pg -strategies s_mesh1
################################################################################
#-------------------------------------------------------------------------------
# S T A N D A R D    C E L L    R A I L    I N S E R T I O N
#-------------------------------------------------------------------------------
################################################################################
create_pg_std_cell_conn_pattern \
    std_cell_rail  \
    -layers {metal1} \
    -rail_width 0.06

set_pg_strategy rail_strat -core \
    -pattern {{name: std_cell_rail} {nets: VDD VSS} }
    
compile_pg -strategies rail_strat    

save_block
##############################################
########### 4. Placement #####################
##############################################
puts "start_place"
copy_block -from_block power_plan_1.design -to placement.design
current_block placement.design

set_app_options -name time.disable_recovery_removal_checks -value false
set_app_options -name time.disable_case_analysis -value false
set_app_options -name place.coarse.continue_on_missing_scandef -value true
set_app_options -name opt.common.user_instance_name_prefix -value place

set_app_options -list {time.delay_calculation_style auto}
set_voltage 0.95
place_opt
legalize_placement
check_legality -verbos

report_qor > ./report/placement/qor.rpt
report_utilization > ./report/placement/utilization.rpt

save_block

##############################################
########### 5. CTS       #####################
##############################################
copy_block -from_block placement.design -to cts.design
current_block cts.design

puts "start_cts"

## CHECKS
#########
report_qor -summary
report_clocks
report_clocks -skew
report_clocks -groups

####################################
## Clock Tree Targets

set_clock_tree_options -target_skew 0.5  -clock [get_clocks *]
set_clock_tree_options -target_latency 0.1  -clock [get_clocks *]

report_clock_tree_options

####################################
## CTS Cell Selection

derive_clock_cell_references -output cts_leq_set.tcl > /dev/null

set CTS_CELLS [get_lib_cells */CLKBUF*]
set_dont_touch $CTS_CELLS false
set_lib_cell_purpose -exclude cts [get_lib_cells] 
set_lib_cell_purpose -include cts $CTS_CELLS

report_lib_cells -objects [get_lib_cells] -columns {name:20 valid_purposes dont_touch}

## CTS NDRs
####################################
set CTS_NDR_MIN_ROUTING_LAYER	"metal4"
set CTS_NDR_MAX_ROUTING_LAYER	"metal5"
set CTS_LEAF_NDR_MIN_ROUTING_LAYER	"metal1"
set CTS_LEAF_NDR_MAX_ROUTING_LAYER	"metal5"
set CTS_NDR_RULE_NAME 		"cts_w2_s2_vlg"
set CTS_LEAF_NDR_RULE_NAME	"cts_w1_s2"

create_routing_rule $CTS_NDR_RULE_NAME\
		-default_reference_rule \
		-taper_distance 0.4 \
		-driver_taper_distance 0.4 \
  	 	-widths   {metal3 0.14 metal4 0.28 metal5 0.28} \
  	 	-spacings {metal3 0.14 metal4 0.28 metal5 0.28}

set_clock_routing_rules -rules $CTS_NDR_RULE_NAME \
		-min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER \
		-max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER
		
report_routing_rules -verbose

report_clock_routing_rules

## Timing and DRC Setup
####################################

#      Ensure that driving cells are specified on all clock ports
report_ports -verbose [get_ports *clk*]
set_driving_cell -scenarios [all_scenarios] -lib_cell CLKBUF_X3 [get_ports *clk*]

report_ports -verbose [get_ports *clk*]

report_clocks -skew
#      Change the uncertainty for all clocks in all scenarios
foreach_in_collection scen [all_scenarios] {
  current_scenario $scen
  set_clock_uncertainty 0.1 -setup [all_clocks]
  set_clock_uncertainty 0.05 -hold [all_clocks]
}

set_app_options -name time.remove_clock_reconvergence_pessimism -value true

report_clock_settings

set_app_options -name clock_opt.flow.enable_ccd -value false
clock_opt

report_qor -summary

report_timing

puts "finish_cts"
save_block

##############################################
########### 6. Routing   #####################
##############################################
copy_block -from_block cts.design -to route.design
current_block route.design
puts "start_route"

# Design should have been loaded using load.tcl

report_qor -summary


#      check for any issues that might cause problems during routing
#      the app option allows for more detailed reporting
set_app_options -name route.common.verbose_level -value 1
check_design -checks pre_route_stage
set_app_options -name route.common.verbose_level -value 0

report_ignored_layers
update_timing

connect_pg_net -net $NDM_POWER_NET [get_pins -hierarchical "*/VDD"]
connect_pg_net -net $NDM_GROUND_NET [get_pins -hierarchical "*/VSS"]
connect_pg_net -net $NDM_POWER_NET [get_ports -physical_context "*/VDD"]
connect_pg_net -net $NDM_GROUND_NET [get_ports -physical_context "*/VSS"]

#      Set application options for the specific routers
set_app_options -name route.global.timing_driven    -value true
set_app_options -name route.global.crosstalk_driven -value false
set_app_options -name route.track.timing_driven     -value true
set_app_options -name route.track.crosstalk_driven  -value true
set_app_options -name route.detail.timing_driven    -value true
set_app_options -name route.detail.force_max_number_iterations -value false

## Routing
####################################
route_auto

check_routes

route_opt
report_qor -summary


puts "finish_route"
save_block
##############################################
########### 7. Finishing #####################
##############################################
copy_block -from_block route.design -to finish.design
current_block finish.design
puts "start_finish"

##create_stdcell_fillers -lib_cells {*decap_?}
##connect_pg_net -automatic
##remove_stdcell_fillers_with_violation
create_stdcell_fillers -lib_cells {FILLCELL*}
connect_pg_net -automatic
remove_stdcell_fillers_with_violation
check_legality
check_lvs
puts "finish_finish"
save_block

##############################################
########### 8. Checks and Outputs ############
##############################################

write_verilog -include {pg_netlist unconnected_ports} ${DESIGN_NAME }.pg.v

write_verilog -exclude {physical_only_cells} -top_module_first ${DESIGN_NAME}.v

write_verilog -include "scalar_wire_declarations diode_cells spare_cells" ${DESIGN_NAME}.lvs.v

write_verilog -include {pg_netlist} ${DESIGN_NAME}_for_pt_v.v

######## SDC_OUT
write_sdc -output ${DESIGN_NAME}.out.sdc
######## SDC_OUT for primetime
write_sdc -output ${DESIGN_NAME}.pt.sdc.tcl -exclude {ideal_network pvt timing_derate} 
write_sdc -output ${DESIGN_NAME}.pt_clock_latency.sdc.tcl -include {clock_latency}
####### SPEF_OUT
report_timing -crosstalk_delta
write_parasitics -format SPEF -output ${DESIGN_NAME}.out.spef
######DEF_OUT
write_def ${DESIGN_NAME}.out.def
##########GDS_OUT
write_gds \
-view design \
-lib_cell_view frame \
-output_pin all \
-fill include \
-exclude_empty_block \
-long_names \
-layer_map "$GDS_MAP_FILE" \
-keep_data_type \
-merge_files "$STD_CELL_GDS"\
./output/${DESIGN_NAME}.gds



save_block
save_lib
exit
close_block
