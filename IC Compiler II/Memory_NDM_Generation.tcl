#--------------------------------------------------
# Script: Memory NDM Generation for Multiple SRAM Macros
# Description:
#   - Reads LEF and multiple CCS timing DBs for each memory macro
#   - Creates a workspace per macro
#   - Generates corresponding NDM files
#--------------------------------------------------

#-------------------------------
# Configuration
#-------------------------------

# Technology file
set tech_file "xx.tf"

# List of memory macros to process
set MEM_LIST "
MEM1
MEM2
MEM3
MEM4
MEM5
MEM6
MEM7
MEM8
"

# Paths to required files
set lef_dir     "SRAM/LEF"
set db_dir      "SRAM/DB"
set mem_ndm_dir "./ndm"

# Bus delimiter configuration
set bus_delimiter {[]}

# Continue execution even if errors occur
set sh_continue_on_error true

#-------------------------------
# Set Common App Options
#-------------------------------

# General workspace and modeling options
set_app_options -as_user_default -name lib.workspace.group_libs_naming_strategies        "common_prefix common_suffix common_prefix_and_common_suffix first_logical_lib_name"
set_app_options -as_user_default -name lib.workspace.group_libs_create_slg              false
set_app_options -as_user_default -name lib.workspace.allow_missing_related_pg_pins      true
set_app_options -as_user_default -name lib.workspace.remove_frame_bus_properties        true
set_app_options -as_user_default -name lib.workspace.save_design_views                  true
set_app_options -as_user_default -name link.require_physical                            true
set_app_options -as_user_default -name design.bus_delimiters                            $bus_delimiter
set_app_options -as_user_default -name lib.logic_model.require_same_opt_attrs           false
set_app_options -as_user_default -name lib.logic_model.use_db_rail_names                true
set_app_options -as_user_default -name lib.logic_model.auto_remove_timing_only_designs  true
set_app_options -as_user_default -name lib.physical_model.connect_within_pin            true
set_app_options -as_user_default -name lib.physical_model.hierarchical                  true
set_app_options -as_user_default -name lib.physical_model.merge_metal_blockage          false
set_app_options -as_user_default -name lib.physical_model.block_all                     auto
set_app_options -as_user_default -name lib.physical_model.preserve_metal_blockage       auto

#-------------------------------
# Process Each Memory Macro
#-------------------------------

foreach mem $MEM_LIST {
    puts "\n### Processing Memory: $mem"

    # Create workspace for this memory
    create_workspace $mem -tech $tech_file

    # Locate LEF file
    set lef_file "${lef_dir}/${mem}.lef"
    if {![file exists $lef_file]} {
        puts "Warning: LEF file not found for $mem: $lef_file"
        continue
    }

    # Read LEF file
    read_lef $lef_file

    # Prepare DB file list for multiple PVTs
    set db_files {}
    foreach pattern {
        "${mem}*ssgnp0p72vm40c.db"
        "${mem}*ssgnp0p72v125c.db"
        "${mem}*ffgnp0p88v125c.db"
        "${mem}*ffgnp0p88vm40c.db"
        "${mem}*tt0p8v85c.db"
    } {
        foreach db [glob -nocomplain "${db_dir}/$pattern"] {
            lappend db_files $db
        }
    }

    # Read all valid DB files
    foreach db $db_files {
        set db_name [file tail $db]
        # Extract process_label from filename: MEMNAME_<view>_<label>.db
        set tokens [split $db_name "_"]
        if {[llength $tokens] >= 3} {
            set label_token [lindex $tokens 2]
            set label_name [lindex [split $label_token "."] 0]
            puts "  - Reading DB: $db (label: $label_name)"
            read_db $db -process_label $label_name
        } else {
            puts "  - Skipping unrecognized DB format: $db_name"
        }
    }

    # Check and commit workspace
    check_workspace -allow_missing
    commit_workspace -output "${mem_ndm_dir}/${mem}.ndm"
    remove_workspace

    puts "✅ Finished: $mem"
}

#-------------------------------
# End of Script
#-------------------------------
