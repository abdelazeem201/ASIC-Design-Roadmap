#####################################################
## Copyright Mentor, A Siemens Business            ##
## All Rights Reserved                             ##
##                                                 ##
## THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY ##
## INFORMATION WHICH ARE THE PROPERTY OF MENTOR    ##
## GRAPHICS CORPORATION OR ITS LICENSORS AND IS    ##
## SUBJECT TO LICENSE TERMS.                       ##
#####################################################
puts "
#####################################################
## Nitro Reference Flow : Import Stage             ##
##                                                 ##
## Imports technology & design info to prepare     ##
## design for NRF place and route.                 ##
#####################################################
"
fk_msg -set_prompt NRF
#config_units -value_type distance -units micro
config_shell -echo_script false

# ==============
# Read libraries and variables
# ==============
if { [info exists MGC_tanner_flow] && $MGC_tanner_flow eq "true"} {
    fk_msg -type info "Running Nitro-AMS : Import Stage" 
} else {
    source import_variables.tcl  
}

set tmpdir [file dirname $sierra_tcl_dir]
set nrf_dir ${tmpdir}/ref_flows/tcl

if { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/scr/kit_utils.tcl] } {
    fk_msg "Sourcing custom NRF script $MGC_nrf_custom_scripts_dir/scr/kit_utils.tcl"
    source $MGC_nrf_custom_scripts_dir/scr/kit_utils.tcl
} else {
    fk_msg "Sourcing standard NRF script $nrf_dir/scr/kit_utils.tcl"
    source $nrf_dir/scr/kit_utils.tcl
}

set MGC_flowStage import

load_utils -name nrf_utils 
load_utils -name save_nrf_import_vars -force

## make sure that user input is valid for all stages
set num_errors [nrf_utils::check_import_variables]
if { $num_errors > 0 } {
    fk_msg -type error "Please fix all errors to continue execution"
    return -code error
}

nrf_utils::save_nrf_import_vars

# ==========
# Multi CPUs
# ==========
config_application -cpus $MGC_cpus
config_timing -cpus $MGC_cpus

# If resuming import after manual floorplanning, skip to post-floorplan for resuming execution

if { ![info exists MGC_resume_import] || !$MGC_resume_import } {

# Read in technology libraries if no library DB exists, else read library DB

if {$MGC_libDbPath =="" || ![file exists $MGC_libDbPath]} {
    fk_msg "MGC_libDbPath : $MGC_libDbPath doesn't exist, Running library setup part of import stage and generate libs.db" 

    # Source the rules.tcl file if provided
    if {$MGC_tech_rules !="" && [file exists $MGC_tech_rules]} {
        fk_msg "Reading TECHNO RULES File"
        source $MGC_tech_rules
    } else {
        fk_msg "Since TECHNO RULE File is not provided or does not exist, technology rules must come from tech lef"
    } 
    # Source the vias.tcl file if provided 
    if {$MGC_tech_vias !="" && [file exists $MGC_tech_vias]} {
        source $MGC_tech_vias
    }
    # Source the dfm_vias.tcl file if provided
    if {$MGC_tech_dfm_vias !="" && [file exists $MGC_tech_dfm_vias]} {
        source $MGC_tech_dfm_vias
    }

    # Tech lef is used instead of rules.tcl for technologies 40nm and above
    if {$MGC_physical_library_tech !="" && [file exists $MGC_physical_library_tech]} {
        fk_msg "Reading TECH LEF File"
        read_lef -file $MGC_physical_library_tech
    }

    if {$MGC_physical_libraries !=""} {
	fk_msg "Reading Cell LEF Files"
	read_lef -files "$MGC_physical_libraries"
    }

    # Read the ptf files
    foreach parasiticsCorner [array name MGC_parasitic_library] {
        fk_msg "Load $parasiticsCorner technology .PTF"
        read_lib $MGC_parasitic_library($parasiticsCorner) -layer_map_file $MGC_itf_to_lef_layer_map -name_prefix $parasiticsCorner
    }

    # Read the lib files
    foreach lib_corner [array name MGC_timing_library] {
        read_library -skip_ccs $MGC_skip_ccs -files $MGC_timing_library($lib_corner) -name_prefix $lib_corner
    }

    # Perform preprocess lib : it has internal check for node won't do any pre-processing for node > 20
    if { [info exists MGC_tanner_flow] && $MGC_tanner_flow eq "true"} {
        #continue 
    } else {
        preprocess_library -categories auto 
    }

    # ====================
    # Save intermediate db
    # ====================

    if {$MGC_split_db} {
        write_db -data lib -file dbs/libs.db
    } else {
        write_db -data all -file dbs/import_libs.db
    }
} else {
    fk_msg "Reading Library Database : $MGC_libDbPath : skipping lib gen step"
    if { [file isfile $MGC_libDbPath] } {
        # Old DB -- Convert to 2.5
        load_utils -name db_utils
        util::update_lib_db -lib_db $MGC_libDbPath
    } else {
        read_db -file $MGC_libDbPath
    }
    file mkdir dbs
    if {![file exists dbs/libs.db]} {
        fk_msg "Creating link dbs/libs.db : $MGC_libDbPath"
        file link -symbolic dbs/libs.db $MGC_libDbPath
    } else { 
        fk_msg -type warning "dbs/libs.db path already exists, make sure MGC_libDbPath is pointing to the same file. All following flow step will use dbs/lib.db"
    }
}

set_analysis_corner fast -enable false
set_analysis_corner slow -enable false
foreach corner $MGC_corners {
    set_analysis_corner -corner $corner \
       			-enable true \
       			-setup true \
       			-hold true \
       			-crpr setup_hold \
       			-library [get_objects electrical_lib *$MGC_CornerTiming($corner)*] \
       			-process [get_libs -type process -filter file=="[string trim $MGC_parasitic_library($MGC_CornerParasitic($corner))]"] \
       			-rc_temp $MGC_CornerTemperature($corner)
}

report_analysis_corner

# ==============
# Import netlist
# ==============
fk_msg "Reading netlist $MGC_importVerilogNetlist"
# to handle correctly tie-up/tie-low connections in a multi-supply design
#TODO: workaround till conver_supply_nets_to_pg is true default
config_default_value -command read_verilog -argument convert_supply_nets_to_pg -value true
if {[info exists MGC_mxdb_flow] && $MGC_mxdb_flow } {
    if {[info exists MGC_mxdb_path] && $MGC_mxdb_path !=""} {
        #read_mxdb -skip { def directives library netlist scandef SDC } -file $MGC_mxdb_path
        read_mxdb -skip { library SDC } -file $MGC_mxdb_path
    } else { 
        fk_msg -type error "MGC_mxdb_flow is set to true : Provide valid path to mxdb by setting MGC_mxdb_path or set MGC_mxdb_flow to false" 
    }
} else {
    read_verilog $MGC_importVerilogNetlist
}

if { [info exists MGC_topDesign] && $MGC_topDesign != "" } {
    current_design $MGC_topDesign
}

# ============
# Avoid assign
# ============
config_optimize -dont_create_assign

# ==========
# Enable ccs
# ==========

if {!$MGC_skip_ccs} {
    fk_msg "Info: Setting delay model to current"
    set_delay_model -base_model current
} else {
    fk_msg "Info: Setting delay model to voltage"
    set_delay_model -base_model voltage
}
report_delay_model

# ===========================
# Define implementation modes
# ===========================
foreach mode $MGC_modes {
    define_design_mode $mode
}
foreach mode $MGC_modes {
    set_design_mode $mode -enable true -corners $MGC_cornersPerMode($mode)
}

set_design_mode default -enable false
report_design_mode

# =============
# Read def file
# ============

if { [info exists MGC_floorLoadDefFile] && $MGC_floorLoadDefFile != "" } {
    read_def -skip {regions} $MGC_floorLoadDefFile
}

if { [info exists MGC_nrf_floorplanning] && $MGC_nrf_floorplanning eq "auto"} {
    if { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/scr/floorplan.tcl] } {
        fk_msg "Sourcing custom NRF script $MGC_nrf_custom_scripts_dir/scr/floorplan.tcl\n"
        source $MGC_nrf_custom_scripts_dir/scr/floorplan.tcl
    } else {
        fk_msg "Sourcing standard NRF script $nrf_dir/scr/floorplan.tcl\n"
        source $nrf_dir/scr/floorplan.tcl
    }
} elseif { $MGC_nrf_floorplanning eq "manual" } {
    fk_msg "###############################################################"
    fk_msg "#  NRF Import suspended for manual floorplanning.             #"
    fk_msg "#  Perform floorplanning as desired.  When complete, execute: #"
    fk_msg "#      resume_nrf_import                                      #"
    fk_msg "#  to resume NRF import flow.                                 #"
    fk_msg "###############################################################\n"
    return
} elseif { $MGC_nrf_floorplanning eq "none" } {
    fk_msg "Skipping NRF floorplanning.\n"
} else {
    fk_msg -type warning "MGC_nrf_floorplanning setting $MGC_nrf_floorplanning is invalid.  Valid values: auto | manual | none.  Skipping NRF floorplanning.\n"
}

} ;  # If manually floorplanning, we will resume import execution here

# Read additional floorplan script if provided

if {[info exists MGC_floorplan_tcl_file] && $MGC_floorplan_tcl_file != ""} {
    if { [file exists $MGC_floorplan_tcl_file] } {
        fk_msg "Sourcing floorplan Tcl file $MGC_floorplan_tcl_file"
        source $MGC_floorplan_tcl_file
    } elseif { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/$MGC_floorplan_tcl_file] } {
        fk_msg "Sourcing floorplan Tcl file $MGC_nrf_custom_scripts_dir/$MGC_floorplan_tcl_file"
        source $MGC_nrf_custom_scripts_dir/$MGC_floorplan_tcl_file
    } else {
        fk_msg -type warning "Could not find file $MGC_floorplan_tcl_file.  Check MGC_floorplan_tcl_file setting."
    }
}

# Read scan DEF file if provided

if {[info exists MGC_scan_def_file] && [string trim $MGC_scan_def_file] !=""} {
    if {[info exists MGC_mxdb_flow] && $MGC_mxdb_flow } {
        fk_msg -type info "Scan DEF is already loaded from mxdb"
    } else {
        read_def -sections {scan_chains} -skip {} -file $MGC_scan_def_file
    }
}

# =================================
# Check design for unresolved cells
# =================================
check_design -check cells
set unresolved_cells [get_cells -of_objects [get_objects -type error -filter @name==unresolved]]
if {[llength $unresolved_cells] > 0} {
  fk_msg -type error "Design has [llength $unresolved_cells] unresolved cells that must be fixed before proceeding."
  foreach c $unresolved_cells {
    puts "\t$c of cell type [get_lib_cell -of $c]"
  }
  exit -1
}

# =======================
# Check for top partition
# =======================

if {[llength [get_top_partition]] == 0} {
  fk_msg -type error "No partition has been created.  Check floorplan and/or input DEF file.\n"
  exit -1
}

# ================
# Check and Re-create tracks
# ================
set node [get_config -name process -param node]
if {$node > 22 || $node=="unknown"} {
    ## Create tracks for nodes above 22nm. 
    fk_msg "Creating new tracks on all layers"
    remove_objects -objects [get_objects -type track]
    create_tracks
} else { 
    check_floorplan -check no_tracks
    set track_errs [get_objects -type error -filter (@category==floorplan)&&(@name==no_tracks)]
    if {[llength $track_errs] } {
        fk_msg -type error "No preferred direction routing tracks on the layers: [get_objects -type layer -of_objects $track_errs]"
        fk_msg  "Review and create tracks on missing layers : using command create_tracks" 
        return -code error
    }
}
# Control generated vias based on user setting or node
if { [info exists MGC_disable_SDA_vias_creation] && $MGC_disable_SDA_vias_creation } {
    config_lib_vias -use_generated false -create false -select true -use_asymmetrical true -use_4cut true
} elseif {$node > 28 || $node=="unknown"} {
    config_lib_vias -use_generated true -create true -select true -use_asymmetrical true -use_4cut true
} else {
    config_lib_vias -use_generate false
}

# Merge net shapes to avoid having false LVS violations
config_lvs -merge_ports true

# =======================
# Read design constraints
# =======================
config_units -value_type time -units nano
fk_msg "Reading constraints"

foreach mode $MGC_modes {
      fk_msg "Loading ${mode} Constraints"
      fk_msg "PT file path $MGC_importConstraintsFile($mode)"
      if {[file extension $MGC_importConstraintsFile($mode)] == ".mxdb" } {
         fk_msg  "Reading Constraints from MXDB for Mode $mode"
         read_mxdb -skip { def directives library netlist scandef } -file $MGC_importConstraintsFile($mode) -nitro_mode $mode
      } else {
          read_constraints \
           -modes $mode \
           -file $MGC_importConstraintsFile($mode) \
           -clock_suffix _${mode}
      }
}

# If no power domains yet exist, read UPF or create default power domain

# check for propagated clocks
nrf_utils::check_for_propagated_clocks

set re_write_lib false

if { [llength [get_objects -type power_domain]] == 0 } {
  if {$MGC_MultiVoltage} {
      fk_msg -type info "Design is multivoltage; setting up MV environment."
      if {[info exists MGC_UPF_File] && $MGC_UPF_File != ""} {
          source $MGC_UPF_File 
      } else {
          fk_msg -type error "No UPF file found for MV setup." 
      }
      if {[info exists MGC_additional_MV_Setup_File] && $MGC_additional_MV_Setup_File != ""} {
         source $MGC_additional_MV_Setup_File
      }

      config_mv -name enable_pgsite_mode -value false      
      config_mv -name const_net_tie_to_related_supply -value true      
      enable_mv
      check_mv

# Re-save libs in case lib cell updates were made in UPF
      set re_write_lib true
  } elseif {[info exists MGC_UPF_File] && $MGC_UPF_File != ""} {
      fk_msg -type info "Design is not MV, but reading UPF file for power intent."
      source $MGC_UPF_File

# Re-save libs in case lib cell updates were made in UPF
      set re_write_lib true
  } else {
      if {$MGC_primary_power_net == "" || $MGC_primary_ground_net == ""} {
        puts ""
        fk_msg -type error "Variables MGC_primary_power_net & MGC_primary_ground_net must be defined in import_variables.tcl.\n"
        exit -1
      }
      fk_msg -type info "Creating default power domain to identify primary power and ground supplies."
      create_power_domain -domain DEFAULT_PD
      create_supply_net $MGC_primary_power_net -domain DEFAULT_PD  -power_net true
      create_supply_net $MGC_primary_ground_net -domain DEFAULT_PD   -power_net false
      set_domain_supply_net -domain DEFAULT_PD -primary_power_net $MGC_primary_power_net -primary_ground_net $MGC_primary_ground_net
  } 
}

if {[lpp::create_cell_edge_constraints]} {
  set re_write_lib true
}

set pgb_lcells [prepare_cell_pg_blockages]
if {[llength $pgb_lcells]} {
  set re_write_lib true
}

# =======
# Save DB
# =======
if {$MGC_split_db} {
    if {$re_write_lib} {
        write_db -data lib -file dbs/libs.db
    }
    write_db -data design -file dbs/import.db
} else {
    write_db -data all -file dbs/import.db
}

# =======
# RUN Import design checks 
# =======
if { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/scr/import_checks.tcl] } {
    fk_msg "Sourcing custom NRF script $MGC_nrf_custom_scripts_dir/scr/import_checks.tcl"
    source $MGC_nrf_custom_scripts_dir/scr/import_checks.tcl
} else {
    fk_msg "Sourcing standard NRF script $nrf_dir/scr/import_checks.tcl"
    source $nrf_dir/scr/import_checks.tcl
}
report_messages

#if { [info exists MGC_no_exit] && $MGC_no_exit } { 
#    #continue 
#} else {
#    exit
#}

#####################################################
## Copyright Mentor, A Siemens Business            ##
## All Rights Reserved                             ##
##                                                 ##
## THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY ##
## INFORMATION WHICH ARE THE PROPERTY OF MENTOR    ##
## GRAPHICS CORPORATION OR ITS LICENSORS AND IS    ##
## SUBJECT TO LICENSE TERMS.                       ##
#####################################################
puts "
#####################################################
## Nitro Reference Flow : Import Stage             ##
##                                                 ##
## Imports technology & design info to prepare     ##
## design for NRF place and route.                 ##
#####################################################
"
fk_msg -set_prompt NRF
#config_units -value_type distance -units micro
config_shell -echo_script false

# ==============
# Read libraries and variables
# ==============
if { [info exists MGC_tanner_flow] && $MGC_tanner_flow eq "true"} {
    fk_msg -type info "Running Nitro-AMS : Import Stage" 
} else {
    source import_variables.tcl  
}

set tmpdir [file dirname $sierra_tcl_dir]
set nrf_dir ${tmpdir}/ref_flows/tcl

if { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/scr/kit_utils.tcl] } {
    fk_msg "Sourcing custom NRF script $MGC_nrf_custom_scripts_dir/scr/kit_utils.tcl"
    source $MGC_nrf_custom_scripts_dir/scr/kit_utils.tcl
} else {
    fk_msg "Sourcing standard NRF script $nrf_dir/scr/kit_utils.tcl"
    source $nrf_dir/scr/kit_utils.tcl
}

set MGC_flowStage import

load_utils -name nrf_utils 
load_utils -name save_nrf_import_vars -force

## make sure that user input is valid for all stages
set num_errors [nrf_utils::check_import_variables]
if { $num_errors > 0 } {
    fk_msg -type error "Please fix all errors to continue execution"
    return -code error
}

nrf_utils::save_nrf_import_vars

# ==========
# Multi CPUs
# ==========
config_application -cpus $MGC_cpus
config_timing -cpus $MGC_cpus

# If resuming import after manual floorplanning, skip to post-floorplan for resuming execution

if { ![info exists MGC_resume_import] || !$MGC_resume_import } {

# Read in technology libraries if no library DB exists, else read library DB

if {$MGC_libDbPath =="" || ![file exists $MGC_libDbPath]} {
    fk_msg "MGC_libDbPath : $MGC_libDbPath doesn't exist, Running library setup part of import stage and generate libs.db" 

    # Source the rules.tcl file if provided
    if {$MGC_tech_rules !="" && [file exists $MGC_tech_rules]} {
        fk_msg "Reading TECHNO RULES File"
        source $MGC_tech_rules
    } else {
        fk_msg "Since TECHNO RULE File is not provided or does not exist, technology rules must come from tech lef"
    } 
    # Source the vias.tcl file if provided 
    if {$MGC_tech_vias !="" && [file exists $MGC_tech_vias]} {
        source $MGC_tech_vias
    }
    # Source the dfm_vias.tcl file if provided
    if {$MGC_tech_dfm_vias !="" && [file exists $MGC_tech_dfm_vias]} {
        source $MGC_tech_dfm_vias
    }

    # Tech lef is used instead of rules.tcl for technologies 40nm and above
    if {$MGC_physical_library_tech !="" && [file exists $MGC_physical_library_tech]} {
        fk_msg "Reading TECH LEF File"
        read_lef -file $MGC_physical_library_tech
    }

    if {$MGC_physical_libraries !=""} {
	fk_msg "Reading Cell LEF Files"
	read_lef -files "$MGC_physical_libraries"
    }

    # Read the ptf files
    foreach parasiticsCorner [array name MGC_parasitic_library] {
        fk_msg "Load $parasiticsCorner technology .PTF"
        read_lib $MGC_parasitic_library($parasiticsCorner) -layer_map_file $MGC_itf_to_lef_layer_map -name_prefix $parasiticsCorner
    }

    # Read the lib files
    foreach lib_corner [array name MGC_timing_library] {
        read_library -skip_ccs $MGC_skip_ccs -files $MGC_timing_library($lib_corner) -name_prefix $lib_corner
    }

    # Perform preprocess lib : it has internal check for node won't do any pre-processing for node > 20
    if { [info exists MGC_tanner_flow] && $MGC_tanner_flow eq "true"} {
        #continue 
    } else {
        preprocess_library -categories auto 
    }

    # ====================
    # Save intermediate db
    # ====================

    if {$MGC_split_db} {
        write_db -data lib -file dbs/libs.db
    } else {
        write_db -data all -file dbs/import_libs.db
    }
} else {
    fk_msg "Reading Library Database : $MGC_libDbPath : skipping lib gen step"
    if { [file isfile $MGC_libDbPath] } {
        # Old DB -- Convert to 2.5
        load_utils -name db_utils
        util::update_lib_db -lib_db $MGC_libDbPath
    } else {
        read_db -file $MGC_libDbPath
    }
    file mkdir dbs
    if {![file exists dbs/libs.db]} {
        fk_msg "Creating link dbs/libs.db : $MGC_libDbPath"
        file link -symbolic dbs/libs.db $MGC_libDbPath
    } else { 
        fk_msg -type warning "dbs/libs.db path already exists, make sure MGC_libDbPath is pointing to the same file. All following flow step will use dbs/lib.db"
    }
}

set_analysis_corner fast -enable false
set_analysis_corner slow -enable false
foreach corner $MGC_corners {
    set_analysis_corner -corner $corner \
       			-enable true \
       			-setup true \
       			-hold true \
       			-crpr setup_hold \
       			-library [get_objects electrical_lib *$MGC_CornerTiming($corner)*] \
       			-process [get_libs -type process -filter file=="[string trim $MGC_parasitic_library($MGC_CornerParasitic($corner))]"] \
       			-rc_temp $MGC_CornerTemperature($corner)
}

report_analysis_corner

# ==============
# Import netlist
# ==============
fk_msg "Reading netlist $MGC_importVerilogNetlist"
# to handle correctly tie-up/tie-low connections in a multi-supply design
#TODO: workaround till conver_supply_nets_to_pg is true default
config_default_value -command read_verilog -argument convert_supply_nets_to_pg -value true
if {[info exists MGC_mxdb_flow] && $MGC_mxdb_flow } {
    if {[info exists MGC_mxdb_path] && $MGC_mxdb_path !=""} {
        #read_mxdb -skip { def directives library netlist scandef SDC } -file $MGC_mxdb_path
        read_mxdb -skip { library SDC } -file $MGC_mxdb_path
    } else { 
        fk_msg -type error "MGC_mxdb_flow is set to true : Provide valid path to mxdb by setting MGC_mxdb_path or set MGC_mxdb_flow to false" 
    }
} else {
    read_verilog $MGC_importVerilogNetlist
}

if { [info exists MGC_topDesign] && $MGC_topDesign != "" } {
    current_design $MGC_topDesign
}

# ============
# Avoid assign
# ============
config_optimize -dont_create_assign

# ==========
# Enable ccs
# ==========

if {!$MGC_skip_ccs} {
    fk_msg "Info: Setting delay model to current"
    set_delay_model -base_model current
} else {
    fk_msg "Info: Setting delay model to voltage"
    set_delay_model -base_model voltage
}
report_delay_model

# ===========================
# Define implementation modes
# ===========================
foreach mode $MGC_modes {
    define_design_mode $mode
}
foreach mode $MGC_modes {
    set_design_mode $mode -enable true -corners $MGC_cornersPerMode($mode)
}

set_design_mode default -enable false
report_design_mode

# =============
# Read def file
# ============

if { [info exists MGC_floorLoadDefFile] && $MGC_floorLoadDefFile != "" } {
    read_def -skip {regions} $MGC_floorLoadDefFile
}

if { [info exists MGC_nrf_floorplanning] && $MGC_nrf_floorplanning eq "auto"} {
    if { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/scr/floorplan.tcl] } {
        fk_msg "Sourcing custom NRF script $MGC_nrf_custom_scripts_dir/scr/floorplan.tcl\n"
        source $MGC_nrf_custom_scripts_dir/scr/floorplan.tcl
    } else {
        fk_msg "Sourcing standard NRF script $nrf_dir/scr/floorplan.tcl\n"
        source $nrf_dir/scr/floorplan.tcl
    }
} elseif { $MGC_nrf_floorplanning eq "manual" } {
    fk_msg "###############################################################"
    fk_msg "#  NRF Import suspended for manual floorplanning.             #"
    fk_msg "#  Perform floorplanning as desired.  When complete, execute: #"
    fk_msg "#      resume_nrf_import                                      #"
    fk_msg "#  to resume NRF import flow.                                 #"
    fk_msg "###############################################################\n"
    return
} elseif { $MGC_nrf_floorplanning eq "none" } {
    fk_msg "Skipping NRF floorplanning.\n"
} else {
    fk_msg -type warning "MGC_nrf_floorplanning setting $MGC_nrf_floorplanning is invalid.  Valid values: auto | manual | none.  Skipping NRF floorplanning.\n"
}

} ;  # If manually floorplanning, we will resume import execution here

# Read additional floorplan script if provided

if {[info exists MGC_floorplan_tcl_file] && $MGC_floorplan_tcl_file != ""} {
    if { [file exists $MGC_floorplan_tcl_file] } {
        fk_msg "Sourcing floorplan Tcl file $MGC_floorplan_tcl_file"
        source $MGC_floorplan_tcl_file
    } elseif { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/$MGC_floorplan_tcl_file] } {
        fk_msg "Sourcing floorplan Tcl file $MGC_nrf_custom_scripts_dir/$MGC_floorplan_tcl_file"
        source $MGC_nrf_custom_scripts_dir/$MGC_floorplan_tcl_file
    } else {
        fk_msg -type warning "Could not find file $MGC_floorplan_tcl_file.  Check MGC_floorplan_tcl_file setting."
    }
}

# Read scan DEF file if provided

if {[info exists MGC_scan_def_file] && [string trim $MGC_scan_def_file] !=""} {
    if {[info exists MGC_mxdb_flow] && $MGC_mxdb_flow } {
        fk_msg -type info "Scan DEF is already loaded from mxdb"
    } else {
        read_def -sections {scan_chains} -skip {} -file $MGC_scan_def_file
    }
}

# =================================
# Check design for unresolved cells
# =================================
check_design -check cells
set unresolved_cells [get_cells -of_objects [get_objects -type error -filter @name==unresolved]]
if {[llength $unresolved_cells] > 0} {
  fk_msg -type error "Design has [llength $unresolved_cells] unresolved cells that must be fixed before proceeding."
  foreach c $unresolved_cells {
    puts "\t$c of cell type [get_lib_cell -of $c]"
  }
  exit -1
}

# =======================
# Check for top partition
# =======================

if {[llength [get_top_partition]] == 0} {
  fk_msg -type error "No partition has been created.  Check floorplan and/or input DEF file.\n"
  exit -1
}

# ================
# Check and Re-create tracks
# ================
set node [get_config -name process -param node]
if {$node > 22 || $node=="unknown"} {
    ## Create tracks for nodes above 22nm. 
    fk_msg "Creating new tracks on all layers"
    remove_objects -objects [get_objects -type track]
    create_tracks
} else { 
    check_floorplan -check no_tracks
    set track_errs [get_objects -type error -filter (@category==floorplan)&&(@name==no_tracks)]
    if {[llength $track_errs] } {
        fk_msg -type error "No preferred direction routing tracks on the layers: [get_objects -type layer -of_objects $track_errs]"
        fk_msg  "Review and create tracks on missing layers : using command create_tracks" 
        return -code error
    }
}
# Control generated vias based on user setting or node
if { [info exists MGC_disable_SDA_vias_creation] && $MGC_disable_SDA_vias_creation } {
    config_lib_vias -use_generated false -create false -select true -use_asymmetrical true -use_4cut true
} elseif {$node > 28 || $node=="unknown"} {
    config_lib_vias -use_generated true -create true -select true -use_asymmetrical true -use_4cut true
} else {
    config_lib_vias -use_generate false
}

# Merge net shapes to avoid having false LVS violations
config_lvs -merge_ports true

# =======================
# Read design constraints
# =======================
config_units -value_type time -units nano
fk_msg "Reading constraints"

foreach mode $MGC_modes {
      fk_msg "Loading ${mode} Constraints"
      fk_msg "PT file path $MGC_importConstraintsFile($mode)"
      if {[file extension $MGC_importConstraintsFile($mode)] == ".mxdb" } {
         fk_msg  "Reading Constraints from MXDB for Mode $mode"
         read_mxdb -skip { def directives library netlist scandef } -file $MGC_importConstraintsFile($mode) -nitro_mode $mode
      } else {
          read_constraints \
           -modes $mode \
           -file $MGC_importConstraintsFile($mode) \
           -clock_suffix _${mode}
      }
}

# If no power domains yet exist, read UPF or create default power domain

# check for propagated clocks
nrf_utils::check_for_propagated_clocks

set re_write_lib false

if { [llength [get_objects -type power_domain]] == 0 } {
  if {$MGC_MultiVoltage} {
      fk_msg -type info "Design is multivoltage; setting up MV environment."
      if {[info exists MGC_UPF_File] && $MGC_UPF_File != ""} {
          source $MGC_UPF_File 
      } else {
          fk_msg -type error "No UPF file found for MV setup." 
      }
      if {[info exists MGC_additional_MV_Setup_File] && $MGC_additional_MV_Setup_File != ""} {
         source $MGC_additional_MV_Setup_File
      }

      config_mv -name enable_pgsite_mode -value false      
      config_mv -name const_net_tie_to_related_supply -value true      
      enable_mv
      check_mv

# Re-save libs in case lib cell updates were made in UPF
      set re_write_lib true
  } elseif {[info exists MGC_UPF_File] && $MGC_UPF_File != ""} {
      fk_msg -type info "Design is not MV, but reading UPF file for power intent."
      source $MGC_UPF_File

# Re-save libs in case lib cell updates were made in UPF
      set re_write_lib true
  } else {
      if {$MGC_primary_power_net == "" || $MGC_primary_ground_net == ""} {
        puts ""
        fk_msg -type error "Variables MGC_primary_power_net & MGC_primary_ground_net must be defined in import_variables.tcl.\n"
        exit -1
      }
      fk_msg -type info "Creating default power domain to identify primary power and ground supplies."
      create_power_domain -domain DEFAULT_PD
      create_supply_net $MGC_primary_power_net -domain DEFAULT_PD  -power_net true
      create_supply_net $MGC_primary_ground_net -domain DEFAULT_PD   -power_net false
      set_domain_supply_net -domain DEFAULT_PD -primary_power_net $MGC_primary_power_net -primary_ground_net $MGC_primary_ground_net
  } 
}

if {[lpp::create_cell_edge_constraints]} {
  set re_write_lib true
}

set pgb_lcells [prepare_cell_pg_blockages]
if {[llength $pgb_lcells]} {
  set re_write_lib true
}

# =======
# Save DB
# =======
if {$MGC_split_db} {
    if {$re_write_lib} {
        write_db -data lib -file dbs/libs.db
    }
    write_db -data design -file dbs/import.db
} else {
    write_db -data all -file dbs/import.db
}

# =======
# RUN Import design checks 
# =======
if { [info exists MGC_nrf_custom_scripts_dir] && $MGC_nrf_custom_scripts_dir != "" && [file exists $MGC_nrf_custom_scripts_dir/scr/import_checks.tcl] } {
    fk_msg "Sourcing custom NRF script $MGC_nrf_custom_scripts_dir/scr/import_checks.tcl"
    source $MGC_nrf_custom_scripts_dir/scr/import_checks.tcl
} else {
    fk_msg "Sourcing standard NRF script $nrf_dir/scr/import_checks.tcl"
    source $nrf_dir/scr/import_checks.tcl
}
report_messages

#if { [info exists MGC_no_exit] && $MGC_no_exit } { 
#    #continue 
#} else {
#    exit
#}

