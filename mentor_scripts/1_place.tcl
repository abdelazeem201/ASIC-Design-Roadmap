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
## Nitro Reference Flow : Place Stage              ##
##                                                 ##
## Loads design from import stage, prepares for    ##
## and then runs run_place_timing                  ##
#####################################################
"
set MGC_flowStage place 
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
            # Old DB -- Convert to 2.5
            util::update_split_db -lib_db dbs/libs.db -design_db dbs/import.db
        } else {
            read_db -file dbs/libs.db
            read_db -file dbs/import.db
        }
        config_default_value -command write_db -argument data -value design
    } else {
        if { [file isfile dbs/import.db] } {
            # Old DB -- Convert to 2.5
            util::update_full_db -design_db dbs/import.db
        } else {
            read_db -file dbs/import.db
        }
    }
}

#Source Custom NDR file before checks
if { [info exist MGC_customNdrFile] && $MGC_customNdrFile != "" } {
    fk_msg -type info "Using Custom NDR File : $MGC_customNdrFile. Please ensure to include set_cts_routing_rule as well in the file."
    source $MGC_customNdrFile
    }


## make sure that user input is valid for all stages
set num_errors 0
incr num_errors [nrf_utils::check_flow_variables $MGC_flowStage]
if { $num_errors > 0 } {
    fk_msg -type error "Please fix all errors to continue execution"
    return -code error
}
util::save_vars

# ===========================================================================================
# START of PLACE STAGE
# ==========================================================================================
check_design 
config_shell -echo_script true

# Target Scenario Management : saving curent scenarios, enabling modes and corners for a stage
nrf_utils::save_scenarios
nrf_utils::configure_scenarios $MGC_flowStage
nrf_utils::check_for_propagated_clocks

# For now only set power corner if user defined
if { $MGC_powerCorner != "" } {
    config_nitro_flow -name power_corner -value $MGC_powerCorner
}

# Target Library Management: preparing and setting dont use cell list : # This Proc is in scr/kit_utils.tcl
nrf_utils::configure_target_libs $MGC_flowStage

# Set routing layers:
if { ![nrf_utils::configure_routing_layers] } {
    return -code error
}

lpp::create_cell_edge_constraints

# Generic configs:
set_crpr_spec -method margin_based
config_default -command compile_scan -argument cross_chain_optimization -value false
config_place_detail -name min_filler_space -value $MGC_min_filler_space

# Use this file to source the needed files to set OCV derates. Can be either "regular OCV" or "AOCV" 
# In case of POCV we recommend to use it starting from POST-CTS stage 
source scr/ocv.tcl
if {$MGC_OCV == "aocv"} {
    fk_msg "Enabling AOCV; please make sure you sourced appropraite AOCV files/settings using src/ocv.tcl"
    config_timing -advanced_ocv true
}
## get_config_value is proc in scr/kit_utils.tcl
if {[get_config_value config_timing parametric_ocv]} { 
    fk_msg -type info "POCV is enabled in import database. Enabling graph based CRPR which is needed for POCV. Pleaase ensure POCV setup is done properly." 
    set_crpr_spec -method graph_based
}

# Prepare path groups
nrf_utils::configure_path_groups

### Avoid assign
config_optimize -dont_create_assign

#############################################################
### Apply NDR to clock nets for congestion estimation
### Priority: 1) MGC_customNdrFile; 2) MGC_CLOCK_NDR_NAME 3) Default, MGC_NdrSpaceMultiplier & MGC_NdrWidthMultiplier
###   MGC_NdrWidthMultiplier and MGC_NdrSpaceMultiplier are prefered way of defining clock NDR
###   If MGC_CLOCK_NDR_NAME is set : NDR with this name must exist 
###   NDR setup uses layers: MGC_CtsBottomPreferredLayer, MGC_CtsTopPreferredLayer, and $MGC_MaxRouteLayer
###   and special vias: MGC_clock_route_ndr_vias 
###   Shielding is controlled by MGC_applyShield, and it uses MGC_clock_shield_net
if { $MGC_customNdrFile == "" } {
    fk_msg -type info "Deriving Clock NDR from technology."
    if { ![nrf_utils::setup_clock_ndr_and_shield] } {
	 return -code error
    }
}

set_rcd_models -stage pre_cts
# Source Timer & Extractor configs
source scr/config.tcl

config_optimize -allow_reroute true -nondef_rule "" 
config_timing -disable_clock_gating_checks false

if {$MGC_place_high_effort_congestion} {
    config_place_timing -name congestion_effort -value high
}

# Clock offset optimization
if { [info exists MGC_activeCorners(place:hold)] && $MGC_activeCorners(place:hold) != "" } {
    config_clockdata_optimize -name hold_corners -value $MGC_activeCorners(place:hold)
}

# WARNING!: Following flow config are not stored in the DB" #
config_flows -preserve_rcd true

### Max Length Constraint to be honored during optimization
set_max_length -length_threshold $MGC_maxLengthParam 
fk_msg "Max Length Set to [report_max_length]"

# constrain the clock maximum transition for better SI results later
nrf_utils::set_clock_based_max_transition

### Define Low power effort OPT effort for RPT
if { $MGC_powerEffort != "none" } {
    config_place_timing -name low_power_effort -value $MGC_powerEffort 
    if { $MGC_saifFile == "" } {
        fk_msg -type warning "Please provide SAIF file when running low power flow. Power analysis will be inaccurate otherwise."
    } else {
        read_saif -file $MGC_saifFile 
        #TODO: Check how to find saif annotation : add it in checks
    }   
    ## create leakage groups and enable optimization leakage control
    set num_groups [ipo_vt_expert -create]
    if { $num_groups >= 2 } {
        config_nitro_flow -name enable_leakage_control -value true
    }
}

### Set buffer and inverter lists for more accurately estimation of the clock offset step
nrf_utils::configure_cts_engine $MGC_flowStage

# constrain the clock ideal transition for better timing convergence
nrf_utils::check_ideal_clock_transitions

nrf_utils::report_timer_configs 
# ===========================================================================================
# RUN_PLACE_TIMING 
# ===========================================================================================
if { [file exists nrf_customization.tcl] } {
    source nrf_customization.tcl
}

## Remove assign
if {$MGC_fix_assigns } {
    ipo_sweep_assigns -place_cell false -message verbose
}

## Enable N2N synthesis : Remapping in 0RC mode
if {$MGC_high_effort_remap} {
    run_0rc_remap
    config_place_timing -name enable_remap_optimization -value true
}

run_place_timing -effort $MGC_flow_effort  -skip_precondition $MGC_skip_precondition -messages verbose 

# Optional additional optimizations to improve timing closure
if { $MGC_enable_pre_cts_incr } {
    source scr/pre_cts_incr.tcl
}
# ===========================================================================================
# END of PLACE STAGE
# ===========================================================================================
if { [file exists dbs/libs.db] } {
    ## split_db is true
    write_db -data design -file dbs/place.db
} else {
    write_db -data all -file dbs/place.db
}
if { $MGC_powerEffort != "none" && $MGC_saifFile != "" } {
    ## Getting one mode to write saif 
    set saifMode [nrf_get_saif_mode $MGC_powerCorner]
    write_saif dbs/place.saif.gz -mode $saifMode
}
nrf_utils::write_reports $MGC_flowStage reports 100

#if { [info exists MGC_no_exit] && $MGC_no_exit eq "true" } { 
#    #continue
#} else {
#    exit
#}

