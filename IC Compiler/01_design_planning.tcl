# 01_design_planning.tcl
set CHIP_LIB "CHIP_LIB"
set TOP      "CHIP"
set CREATE_CELL_FILE "../script/create_phy_cell.tcl"
set TDF_FILE "../design_data/io.tdf"
set POWER  "VDD"
set GROUND "VSS"
#======================================================================
# Open Design
#======================================================================
#open_mw_lib $CHIP_LIB
#open_mw_cel $TOP
#======================================================================
# Before reading io_constraints(*.TDF), you must create cell
# Create I/O Cells======================================================================
source $CREATE_CELL_FILE
#======================================================================
# Read a IO Constraint file
#======================================================================
set IO_SPACE 8.5 ; # 5~10
read_pin_pad_physical_constraints $TDF_FILE
#======================================================================
# Initialize the Floorplan
#======================================================================
set CORE_PAD_SPACE 90 ;
create_floorplan -core_aspect_ratio 1 -core_utilization 0.6 -flip_first_row -left_io2core $CORE_PAD_SPACE -right_io2core $CORE_PAD_SPACE -bottom_io2core $CORE_PAD_SPACE -top_io2core $CORE_PAD_SPACE
#=====================================================================
# Insert PAD Filler
#=====================================================================
insert_pad_filler -cell {PFILLER20 PFILLER10 PFILLER5 PFILLER1 PFILLER05 PFILLER0005} -overlap_cell {PFILLER0005} ; # overlap_cell means smallest filler cell
#=====================================================================
# Save Design
#=====================================================================
save_mw_cel $TOP
save_mw_cel -as "init_floor_plan"
#=====================================================================
# Set Macro Placement Constraints
# - Memory margin constraints
#======================================================================
#set_keepout_margin -all_macros -type hard -outer {20 20 20 20}
#======================================================================
# Set Routing Blockage
#=====================================================================
#create_route_guide -no_signal_layer {METAL5 METAL6} -coordinate {{20 20} {75 95}}
#=====================================================================
# Place Standard and Macro Cells
# 1st Compile
#=====================================================================
set_host_options -max_cores 4
create_fp_placement -timing_driven -effort high -num_cpus 4
#set_dont_touch_placement [all_macro_cells]
#=====================================================================
# Connect P/G Nets
#=====================================================================
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
#=====================================================================
# Set Power Network Constraints
# set_fp_rail_constraints  # set rail synthesis constraints
#       -add_layer             (add layer constraints) (strap)
#       -set_ring              (set ring constraints)
#       -set_global            (set global constraints)
#======================================================================
set H_LAYER M6
set V_LAYER M5
set STRAP_WIDTH 4
 
set_fp_rail_constraints -add_layer -layer $H_LAYER \
    -direction horizontal \
    -max_strap 15 -min_strap 10 \
    -max_width $STRAP_WIDTH -min_width $STRAP_WIDTH \
    -spacing minimum
 
set_fp_rail_constraints -add_layer -layer $V_LAYER \
    -direction vertical \
    -max_strap 15 -min_strap 10 \
    -max_width $STRAP_WIDTH -min_width $STRAP_WIDTH \
    -spacing minimum
 
set_fp_rail_constraints -set_ring -nets \
    [format  "%s %s %s %s %s %s %s %s" \
    $POWER $GROUND $POWER $GROUND $POWER $GROUND $POWER $GROUND] \
    -horizontal_ring_layer $H_LAYER \
    -vertical_ring_layer $V_LAYER \
    -ring_width 4 \
    -ring_spacing 4 \
    -ring_offset 4 \
    -extend_strap core_ring
 
set_fp_rail_constraints -set_global \
    -no_routing_over_hard_macros \
    -no_same_width_sizing \
    -keep_ring_outside_core
 
# For memory block
#set_fp_block_ring_constraints -add -horizontal_layer H_LAYER \
#   -horizontal_width 8 \
#    -horizontal_offset 1 \
#    -vertical_layer V_LAYER \
#    -vertical_width 8 \
#    -vertical_offset 1 \
#    -block_type master  \
#    -block {rom_128x12_t90} \
#    -net  {VDD VSS}
 
#======================================================================
# Running Power Network Synthesis
#       -voltage_supply : 1V for T90 ; 0.9V for T40
#       -power_budget : unit:mW
#======================================================================
synthesize_fp_rail -nets [list $POWER $GROUND] \
    -voltage_supply 0.9 \
    -synthesize_power_plan \
    -power_budget 30
 
#======================================
# Note :
#     check IR drop map after this command
#======================================================================
# Commit Power Plan
#======================================================================
commit_fp_rail
#======================================================================
# Save Design
#======================================================================
save_mw_cel  -design [format  "%s%s" $TOP ".CEL;1"]
save_mw_cel  -design [format  "%s%s" $TOP ".CEL;1"] -as "design_planning"
