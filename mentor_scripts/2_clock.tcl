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
## Nitro Reference Flow : Clock Stage              ##
##                                                 ##
## Loads design from place stage, prepares for     ##
## and then runs run_clock_timing                  ##
#####################################################
"

set MGC_flowStage clock
fk_msg -set_prompt NRF

###Setting design and technology variables
source flow_variables.tcl
source scr/kit_utils.tcl
load_utils -name nrf_utils 
load_utils -name save_vars
load_utils -name db_utils

config_application -cpus $MGC_cpus
config_timing -cpus $MGC_cpus

# Read db
if {![string length [get_top_partition]]} {
    if { [file exists dbs/libs.db] } {
	## split_db is true
        if { [file isfile dbs/libs.db] } {
            util::update_split_db -lib_db dbs/libs.db -design_db dbs/place.db
        } else {
            read_db -file dbs/libs.db
            read_db -file dbs/place.db
        }
        config_default_value -command write_db -argument data -value design
    } else {
        if { [file isfile dbs/place.db] } {
            util::update_full_db -design_db dbs/place.db
        } else {
            read_db -file dbs/place.db
        }
    }
}
set num_errors [nrf_utils::check_flow_variables $MGC_flowStage]
if { $num_errors > 0 } {
    fk_msg -type error "Please fix all errors to continue execution"
    return -code error
}
util::save_vars

# ===========================================================================================
# START of CLOCK STAGE
# ==========================================================================================
check_design 
config_shell -echo_script true

# ===========================================================================================
# Default settings
# ===========================================================================================
# Objective for automated CTS repeater selection
set MGC_cts_repeater_pruning_objective delay ; # Valid values: area delay driver_res input_cap leakage total_power

# CG Pruning settings
set MGC_ck_cg_apply_pruning true

# Usage of dont_use cells for GC Optimization
set MGC_ck_cg_use_dont_use false

# CTS engine tuning
set cts_partition_skew_threshold 0.50
set cts_compile_local_refine_skew_factor 0.30
set cts_intrinsic_repeater_delay_new true

# ===========================================================================================
# TECHNO / LIB 
# ===========================================================================================

# Don't let the tool use its own generated vias 
# Generated vias rules are provided
set node [get_config -name process -param node]
if {$node > 28 || $node=="unknown"} {
    config_lib_vias -use_generated  true -create true -select true -use_asymmetrical true -use_4cut true
} else {
    config_lib_vias -use_generate false
}

# ===========================================================================================
# GENERIC  
# ===========================================================================================

config_name_rule -cell CLOCK -net CLOCK
config_timing -use_annotated_cts_offsets false

# ===========================================================================================
# GR 
# ===========================================================================================
config_route_global -category user_defined
fk_msg "Applying NRF non-default GR settings"
config_route_global -name gr_full_timing_update_thresh -value 0.0

# ===========================================================================================
# TIMING CONSTRAINTS - MCMM
# ===========================================================================================
if {[file exists scr/reload_constraints_${MGC_flowStage}.tcl]} {
    source scr/reload_constraints_${MGC_flowStage}.tcl
}
nrf_utils::configure_scenarios $MGC_flowStage
nrf_utils::configure_target_libs $MGC_flowStage

# Set routing layers:
if { ![nrf_utils::configure_routing_layers] } {
    return -code error
}

lpp::create_cell_edge_constraints

#constraining clock transition for SI
nrf_utils::set_clock_based_max_transition

# Force tight max_transition constraint on macros' data pins
if { $MGC_max_trans_on_macro_pins_value != 0 } {
    foreach pin [ get_pins -of_objects [ get_cells -filter is_macro ] -filter direction==in&&!@is_clock_pin ] {
        set_max_transition $MGC_max_trans_on_macro_pins_value [ get_pins $pin ]
    }
}

# ===========================================================================================
# OCV - CRPR 
# ===========================================================================================
# Use this file to source the needed files to set OCV derates. Can be either "regular OCV" or "AOCV" or "POCV" 
source scr/ocv.tcl
if {$MGC_OCV == "aocv"} {
    fk_msg "Enabling AOCV; please make sure you sourced appropraite AOCV files/settings using src/ocv.tcl"
    config_timing -advanced_ocv true
}
if {$MGC_OCV== "pocv"} {
    fk_msg "Enabling POCV; please make  sure you sourced appropraite POCV files/settings using scr/ocv.tcl"
    config_timing -parametric_ocv true
    config_report_timing -add_columns variation
}
set_crpr_spec -method graph_based
set_crpr_spec -crpr_threshold $MGC_crpr_threshold
source scr/config.tcl

# ===========================================================================================
# HOLD 
# ===========================================================================================
set_property -name is_dont_use -value true -objects [get_lib_cells $MGC_DLY_cells]
config_flows -hold_opt_cell_list [ get_lib_cells $MGC_DLY_cells ]

# ===========================================================================================
# MV - POWER 
# ===========================================================================================
if { $MGC_powerEffort != "none" && $MGC_saifFile != "" } {
    read_saif -file dbs/place.saif.gz
} 
## Define Low power effort OPT effort for RCT
if { $MGC_powerEffort != "none"} {
    config_clock_timing -name low_power_effort -value $MGC_powerEffort
}
if { $MGC_powerCorner != {} } { 
    config_clock_timing -name dont_prune_corners -value $MGC_powerCorner
}

# ===========================================================================================
# CTS
# ===========================================================================================
nrf_utils::configure_cts_engine $MGC_flowStage

config_clock_timing -name refine_cts -value $MGC_clock_refine_cts
fk_msg "Cleaning up NRF-generated pre-existing NDR/Shield rules on clock nets before CTS Buffering. Custom rules, if any,  are kept."
set candidate_nets [filter_collection [collect_clock_nets] -expression "@nondefault_rule~=MGC_CLK_NDR_*"]
if {[sizeof_collection $candidate_nets] > 0} {
	set_property -name nondefault_rule -value "" -object $candidate_nets
	set_property -name shield_rule -value "" -object $candidate_nets
}

nrf_utils::report_timer_configs 

# ===========================================================================================
# RUN_CLOCK_TIMING 
# ===========================================================================================
config_clock_timing -name preserve_rcd_models -value true
config_clock_timing -name enable_optimize_clock_tree -value $MGC_enable_clock_data_opt
# Preserving CTS Reference corner from Pruning
set current_excluded_corners_for_pruning [config_clock_timing -name dont_prune_corners]
config_clock_timing -name dont_prune_corners -value [add_to_collection -unique true -object [get_corners $current_excluded_corners_for_pruning] -add [get_corners $::MGC_activeCorners(clock:ref)]]

###Max length constraint for optimization
config_optimize -buffer_removal_max_length_limit $MGC_maxLengthParam

if { [file exists nrf_customization.tcl] } {
    source nrf_customization.tcl
}

run_clock_timing -cpus $MGC_cpus

## Insert tie-cells
if {$MGC_tie_low_cell ne "" && $MGC_tie_high_cell ne ""} {
    nrf_utils::insert_tie_cells
    fk_msg -type info "Running tie cells insertion."
} else {
    fk_msg -type info "Skipping tie cells insertion."
}
# ===========================================================================================
# END of CLOCK STAGE
# ===========================================================================================
if { [file exists dbs/libs.db] } {
    ## split_db is true
    write_db -data design -file dbs/clock.db
} else {
    write_db -data all -file dbs/clock.db
}
if { $MGC_powerEffort != "none" && $MGC_saifFile != "" } {
    ## Getting one mode to write saif 
    set saifMode [nrf_get_saif_mode $MGC_powerCorner]
    write_saif dbs/clock.saif.gz -mode $saifMode
}
nrf_utils::write_reports $MGC_flowStage reports 100

#if { [info exists MGC_no_exit] && $MGC_no_exit eq "true" } { 
#    #continue
#} else {
#    exit
#}

