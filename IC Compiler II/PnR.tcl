set_host_options -max_cores 16
source ./input/common_setup.tcl

set link_library $LINK_LIBRARY_FILES_MVT
set target_library $TARGET_LIBRARY_FILES_MVT

set power "VDD"
set ground "VSS"
create_lib -ref_libs $NDM_REFERENCE_LIB_DIRS_MVT -technology $TECH_FILE ../work/chiptop

read_parasitic_tech -tlup $TLUPLUS_MAX_FILE -layermap $MAP_FILE
read_parasitic_tech -tlup $TLUPLUS_MIN_FILE -layermap $MAP_FILE

set TOP_DESIGN ChipTop
set gate_verilog "../../dc/output/compile.v"

read_verilog -top $TOP_DESIGN $gate_verilog
current_design $TOP_DESIGN

set_attribute [get_layers M1] routing_direction vertical
set_attribute [get_layers M2] routing_direction horizontal
set_attribute [get_layers M3] routing_direction vertical
set_attribute [get_layers M4] routing_direction horizontal
set_attribute [get_layers M5] routing_direction vertical
set_attribute [get_layers M6] routing_direction horizontal
set_attribute [get_layers M7] routing_direction vertical
set_attribute [get_layers M8] routing_direction horizontal
set_attribute [get_layers M9] routing_direction vertical
set_attribute [get_layers MRDL] routing_direction horizontal

set_wire_track_pattern -site_def unit -layer M1 -mode uniform -mask_constraint{mask_two mask_one} 
\-coord 0.037 -space 0.074 -direction vertical

source ../scripts/mcmm.tcl

#./output/ChipTop_pads.v

initialize_floorplan \ -flip_first_row true \ -boundary {{0 0} {400 400}} \ -core_offset {15 15 15 15}

place_pins -ports [get_ports *]

create_net -power $NDM_POWER_NET
create_net -ground $NDM_GROUND_NET

connect_pg_net -net $NDM_POWER_NET [get_pins -hierarchical "*/VDD"]
connect_pg_net -net $NDM_GROUND_NET [get_pins -hierarchical "*/VSS"]

#########################################SRAMs'Placement################################################################
set sram_width 54.468
set sram_space 40
set sram_start_x 55.4690
set sram_start_y 246.60

set_attribute [get_cells MemYHier_MemXb] orientation R0
set_attribute [get_cells MemYHier_MemXa] orientation R0
set_attribute [get_cells MemXHier_MemXb] orientation R0
set_attribute [get_cells MemXHier_MemXa] orientation R0
set_attribute [get_cells MemYHier_MemXb] origin "$sram_start_x $sram_start_y"
set_attribute [get_cells MemYHier_MemXa] origin "[expr $sram_start_x + $sram_width 
+ $sram_space] $sram_start_y"
set_attribute [get_cells MemXHier_MemXb] origin "[expr $sram_start_x + 
2*($sram_width + $sram_space)] $sram_start_y"
set_attribute [get_cells MemXHier_MemXa] origin "[expr $sram_start_x + 
3*($sram_width + $sram_space)] $sram_start_y"
set_fixed_objects [get_cell MemXHier_MemXa]
set_fixed_objects [get_cell MemXHier_MemXb]
set_fixed_objects [get_cell MemYHier_MemXa]
set_fixed_objects [get_cell MemYHier_MemXb]
create_keepout_margin -type hard -outer {20 20 20 20} [get_cells Mem?Hier_MemX?]

###################################################################################
#########################################
create_placement -floorplan -timing_driven
legalize_placement
#########################################Routing Blockages On Macro 
Cells################################################################
create_routing_blockage -layers {M1 M2 M3 M4 M5} -boundary [get_attribute 
[get_cells MemXHier_MemXa] boundary]
create_routing_blockage -layers {M1 M2 M3 M4 M5} -boundary [get_attribute 
[get_cells MemYHier_MemXa] boundary]
create_routing_blockage -layers {M1 M2 M3 M4 M5} -boundary [get_attribute 
[get_cells MemXHier_MemXb] boundary]
create_routing_blockage -layers {M1 M2 M3 M4 M5} -boundary [get_attribute 
[get_cells MemYHier_MemXb] boundary]
####Connect P/G Pins and Create Power Rails#################
create_pg_mesh_pattern P_top_two \
-layers { \
{ {horizontal_layer: M7} {width: 0.2} {spacing: interleaving} {pitch: 
30} {offset: 0.856} {trim : true} } \
{ {vertical_layer: M6} {width: 0.2} {spacing: interleaving} {pitch: 
30} {offset: 6.08} {trim : true} } \
} 
set_pg_strategy S_default_vddvss \
-core \
-pattern { {name: P_top_two} {nets:{VSS VDD}} } \
-extension { {{stop:design_boundary_and_generate_pin}} }
compile_pg -strategies {S_default_vddvss} 
remove_routing_blockages *
####Rings Creation Around Macro Cells#################
set macro_list {MemXHier_MemXa MemYHier_MemXa MemXHier_MemXb MemYHier_MemXb} 

create_pg_ring_pattern P_HM_ring -horizontal_layer M7 -horizontal_width {1} -vertical_layer M6 -vertical_width {1} -corner_bridge false
set_pg_strategy S_HM_ring_top -macros $macro_list -pattern { {pattern: 
P_HM_ring} {nets: {VSS VDD}} {offset: {0.1 0.1}} }
compile_pg -strategies {S_HM_ring_top } 
create_routing_blockage -layers * -boundary { {45 425} {305 617} }
## Create std rail
#VDD VSS
create_pg_std_cell_conn_pattern std_rail_conn1 -rail_width 0.094 -layers M1
set_pg_strategy std_rail_1 -pattern {{name : std_rail_conn1} {nets: "VDD VSS"}} -core
compile_pg -strategies std_rail_1

###################################################################################
###########################
############place_opt#################################
set_app_options -name time.disable_recovery_removal_checks -value false
set_app_options -name time.disable_case_analysis -value false
set_app_options -name place.coarse.continue_on_missing_scandef -value true
place_opt
legalize_placement
report_placement
###################################################################################
#########################
## std filler
set pnr_std_fillers "SAEDRVT14_FILL*"
set std_fillers ""
foreach filler $pnr_std_fillers { lappend std_fillers "*/${filler}" }
create_stdcell_filler -lib_cell $std_fillers
connect_pg_net -net $power [get_pins -hierarchical "*/VDD"]
connect_pg_net -net $ground [get_pins -hierarchical "*/VSS"]
remove_cells [get_cells -filter ref_name=~"*FILL*" ]
#########################Setting CTS Options###############################
remove_routing_blockages *
create_routing_rule ROUTE_RULES_1 \
 -widths {M3 0.2 M4 0.2 } \
 -spacings {M3 0.42 M4 0.63 }
set_clock_routing_rules -rules CLK_SPACING -min_routing_layer M2 -max_routing_layer
M4
set_clock_tree_options -target_latency 0.000 -target_skew 0.000 
###################################################################################
###########################
############clock_opt#################################