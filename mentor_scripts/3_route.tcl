# ==================================================================
#  NITRO  KIT
#  Task : routing
#  Description: track/detail routing and final timing driven routing
# ==================================================================
puts "
#####################################################
## Nitro Reference Flow : Route Stage              ##
##                                                 ##
## Loads design from clock stage, prepares for     ##
## and then runs run_route_timing                  ##
#####################################################
"

set MGC_flowStage route
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
	# Split db is used
        if { [file isfile dbs/libs.db] } {
            # Old DB -- Convert to 2.5
            util::update_split_db -lib_db dbs/libs.db -design_db dbs/clock.db
        } else {
            read_db -file  dbs/libs.db
            read_db -file  dbs/clock.db
        }
        config_default_value -command write_db -argument data -value design
    } else {
        if { [file isfile dbs/clock.db] } {
            # Old DB -- Convert to 2.5
            util::update_full_db -design_db dbs/clock.db
        } else {
            read_db -file dbs/clock.db
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
# START of ROUTE STAGE
# ==========================================================================================
check_design 

config_shell -echo_script true
set MGC_rrt_opt true

# Don't let the tool use its own generated vias 
# Generated vias rules are provided
set node [get_config -name process -param node]
if {$node > 28 || $node=="unknown"} {
    config_lib_vias -use_generated  true -create true -select true -use_asymmetrical true -use_4cut true
} else {
    config_lib_vias -use_generate false
}

lpp::create_cell_edge_constraints

if { $MGC_powerEffort != "none" && $MGC_saifFile != "" } {
    read_saif -file dbs/clock.saif.gz
} 

# Target Scenario Management : enabling modes and corners 
# This Proc is in scr/kit_utils.tcl
nrf_utils::configure_scenarios $MGC_flowStage
# Target Library Management: preparing and setting dont use cell list
# This Proc is in scr/kit_utils.tcl
if {$MGC_rrt_opt} {
    nrf_utils::configure_target_libs $MGC_flowStage
}

# Generic configs:
config_timing -disable_clock_gating_checks false
set_crpr_spec -method graph_based

# Routing flow will set 2 rcd models internally: Postcts at first & then post_route after track routing
# All user specified engine settings will be honored 
config_flows -preserve_rcd false
source scr/config.tcl

config_route_timing -reset_all 

# Enable DFM optimization by replacing DFM vias
if {$MGC_replace_dfm} {
    config_route_timing -name dvia_mode -value dfm
}

## Define Low power effort OPT effort for RRT
if { $MGC_powerEffort != "none"} {
    config_route_timing -name low_power_effort -value $MGC_powerEffort
}

## check if design is legal, if not - error
if { [config_place_detail -name follow_drc_for] == {} } {
    config_place_detail -name follow_drc_for -reset
    set illegal_cells [get_illegal_cells]
    if { [llength $illegal_cells] } {
	fk_msg -type warning  "Flow was run with suppressed pre_route checks during legalization. As a result [llength $illegal_cells] cells are illegal."
	#return -code error "Stop the flow due to illegal cells"
    }
}

# ===========================================================================================
# RUN_ROUTE_TIMING 
# ===========================================================================================

if { [file exists nrf_customization.tcl] } {
    source nrf_customization.tcl
}

if {$MGC_rrt_opt} {
    # configs for extraction in DR
    config_extraction -use_thickness_variation false
    config_extraction -use_thickness_variation_for_cap false
    config_extraction -use_thickness_variation_for_res true
    # CRPR
    set_crpr_spec -crpr_threshold $MGC_crpr_threshold
    set_crpr_spec -method graph_based
    set_crpr_spec -transition same_transition
    ### Max Length Constraint to be honored during optimization
    fk_msg "Max Length Constraint"
    set_max_length -length_threshold $MGC_maxLengthParam 
    fk_msg "Max Length Set to [report_max_length]"
    fk_msg "Running RRT with Interleave Optimization"
    run_route_timing -mode interleave_opt -cpus $MGC_cpus -messages verbose
} else {
    run_route_timing -cpus $MGC_cpus -messages verbose
}
# ===========================================================================================
# END of ROUTE STAGE
# ===========================================================================================
if { [file exists dbs/libs.db] } {
    ## split_db is true
    write_db -data design -file dbs/route.db
} else {
    write_db -data all -file dbs/route.db
}
if { $MGC_powerEffort != "none" && $MGC_saifFile != "" } {
    ## Getting one mode to write saif 
    set saifMode [nrf_get_saif_mode $MGC_powerCorner]
    write_saif dbs/route.saif.gz -mode $saifMode
}
nrf_utils::write_reports $MGC_flowStage reports 100

#if { [info exists MGC_no_exit] && $MGC_no_exit eq "true" } { 
#    #continue
#} else {
#    exit
#}

