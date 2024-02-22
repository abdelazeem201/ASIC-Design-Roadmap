set_host_options -max_cores 16
source ./input/common_setup.tcl

set link_library $LINK_LIBRARY_FILES_MVT
set target_library $TARGET_LIBRARY_FILES_MVT

set power "VDD"
set ground "VSS"
create_lib -ref_libs $NDM_REFERENCE_LIB_DIRS_MVT -technology $TECH_FILE../work/chiptop

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

set_wire_track_pattern -site_def unit -layer M1 -mode uniform -mask_constraint{mask_two mask_one} \-coord 0.037 -space 0.074 -direction vertical

source ../scripts/mcmm.tcl

#./output/ChipTop_pads.v

initialize_floorplan \ -flip_first_row true \ -boundary {{0 0} {400 400}} \ -core_offset {15 15 15 15}

place_pins -ports [get_ports *]

create_net -power $NDM_POWER_NET
create_net -ground $NDM_GROUND_NET

connect_pg_net -net $NDM_POWER_NET [get_pins -hierarchical "*/VDD"]
connect_pg_net -net $NDM_GROUND_NET [get_pins -hierarchical "*/VSS"]