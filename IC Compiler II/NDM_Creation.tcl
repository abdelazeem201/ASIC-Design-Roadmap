#---------------------------------------------------------------------
# Script to create a Synopsys NDM Workspace for a standard cell library
# with multiple PVT corners and physical data
#----------------------------------------------------------------------

#-------------------------------
# Configuration Section
#-------------------------------

# Technology file (defines layers, rules, etc.)
set tech_file "xxx.tf"

# Physical-only NDM file (contains placement, pin info, etc.)
set physical_ndm "_physicalonly.ndm"

# Directory paths
set lef_dir      "LEF"
set db_dir       "db"

# Library name
set lib_name     "lib_name"

# Bus delimiter for naming convention
set bus_delimiter {[]}

# Ensure script continues even if errors occur
set sh_continue_on_error true

#-------------------------------
# App Options Setup
#-------------------------------

# Set workspace-related options for better library merging and naming
set_app_options -as_user_default -name lib.workspace.group_libs_naming_strategies "common_prefix common_suffix common_prefix_and_common_suffix first_logical_lib_name"
set_app_options -as_user_default -name lib.workspace.group_libs_create_slg false
set_app_options -as_user_default -name lib.workspace.allow_missing_related_pg_pins true
set_app_options -as_user_default -name lib.workspace.remove_frame_bus_properties true
set_app_options -as_user_default -name lib.workspace.save_design_views true
set_app_options -as_user_default -name link.require_physical true

# Set delimiter options for bus structures
set_app_options -as_user_default -name design.bus_delimiters $bus_delimiter

# Logic model configuration
set_app_options -as_user_default -name lib.logic_model.require_same_opt_attrs false
set_app_options -as_user_default -name lib.logic_model.use_db_rail_names true
set_app_options -as_user_default -name lib.logic_model.auto_remove_timing_only_designs true

# Physical model configuration
set_app_options -as_user_default -name lib.physical_model.connect_within_pin true
set_app_options -as_user_default -name lib.physical_model.hierarchical true
set_app_options -as_user_default -name lib.physical_model.merge_metal_blockage false
set_app_options -as_user_default -name lib.physical_model.block_all auto
set_app_options -as_user_default -name lib.physical_model.preserve_metal_blockage auto

#-------------------------------
# Workspace Initialization
#-------------------------------

# Create a new workspace using the tech file
create_workspace STD -tech $tech_file -flow normal

# Read physical-only NDM data
read_ndm $physical_ndm

#-------------------------------
# Read CCS Timing DB Files per PVT Corner
#-------------------------------
foreach pvt {pvt1 pvt2} {
    set db_file [glob $db_dir/${lib_name}${pvt}_ccs.db]
    if {[file exists $db_file]} {
        read_db $db_file -process_label $pvt
    } else {
        puts "Warning: Missing DB file for $pvt: $db_file"
    }
}

#-------------------------------
# Setup Site Attributes
#-------------------------------

# Set default site (typically used for placement grid)
set_attribute [get_site_defs unit] is_default true
set_attribute [get_site_defs unit] symmetry Y

#-------------------------------
# Routing Layer Direction Setup
#-------------------------------

# Define vertical and horizontal routing layers
set routing_layers_vertical   {M0 M3 M5 M7 M9 M11}
set routing_layers_horizontal {M1 M2 M4 M6 M8 M10 AP}

# Set routing directions
set_attribute [get_layers $routing_layers_vertical]   routing_direction vertical
set_attribute [get_layers $routing_layers_horizontal] routing_direction horizontal

#-------------------------------
# Power Pin Attributes
#-------------------------------

# Classify special VPP power pins as primary power
foreach pattern {"*/TAP*VPP*VSS*/VPP" "*/TAP*VPP*VBB*/VPP"} {
    set_attribute -o [get_lib_pins $pattern] port_type power
    set_attribute -o [get_lib_pins $pattern] pg_type   primary
}

#-------------------------------
# Diode Cell Identification
#-------------------------------

# Identify antenna diode cells and mark accordingly
set diode_cells [get_object_name [get_lib_cells */ANTENNA*]]
foreach diode $diode_cells {
    puts "Marking diode cell: $diode"
    set_attr -q [get_lib_pins -q $diode/I] -name is_diode -value true 
    set_attr -q -o [get_lib_cells -q $diode] -name is_diode_cell -value true 
}

#-------------------------------
# Final Workspace Checks and Commit
#-------------------------------

# Check workspace consistency, allow missing views
check_workspace -allow_missing

# Save the final workspace as an NDM file
commit_workspace -output "${lib_name}.ndm"

# Clean up
remove_workspace

#-------------------------------
# End of Script
#-------------------------------
