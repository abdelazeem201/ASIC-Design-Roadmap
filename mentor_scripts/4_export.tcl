######################################################
### Copyright Mentor, A Siemens Business            ##
### All Rights Reserved                             ##
###                                                 ##
### THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY ##
### INFORMATION WHICH ARE THE PROPERTY OF MENTOR    ##
### GRAPHICS CORPORATION OR ITS LICENSORS AND IS    ##
### SUBJECT TO LICENSE TERMS.                       ##
######################################################
puts "
######################################################
#  Export Flow                                       #
#                                                    #
#  Fix process antennas, add fillers & metal fill    #
#  Output design data.                               #
#  Control vars defined in flow_variables.tcl        #
#                                                    #
######################################################
"

config_shell -echo_script false
fk_msg -set_prompt NRF

###Sourcing design and technology variables
source flow_variables.tcl
source scr/kit_utils.tcl
load_utils -name nrf_utils 
load_utils -name save_vars
load_utils -name db_utils

set MGC_flowStage export

# Read DB
if {![string length [get_top_partition]]} {
    if { [file exists dbs/libs.db] } {
	# Split db is used
        if { [file isfile dbs/libs.db] } {
            # Old DB -- Convert to 2.5
            util::update_split_db -lib_db dbs/libs.db -design_db dbs/route.db
        } else {
	    read_db -file dbs/libs.db
	    read_db -file dbs/route.db
        }
	config_default_value -command write_db -argument data -value design
    } else {
        if { [file isfile dbs/route.db] } {
            # Old DB -- Convert to 2.5
            util::update_full_db -design_db dbs/route.db
        } else {
	    read_db -file dbs/route.db
        }
    }
}

set num_errors [nrf_utils::check_flow_variables $MGC_flowStage]
if { $num_errors > 0 } {
    fk_msg -type error "Please fix all errors to continue execution"
    return -code error
}
util::save_vars

lpp::create_cell_edge_constraints

## Fix Antenna
set MGC_fix_antenna true             ; # Mandatory to review : true|false

if { [file exists nrf_customization.tcl] } {
    source nrf_customization.tcl
}

if {$MGC_fix_antenna eq true} {
    check_antenna -cpus $MGC_cpus
    fix_antenna -method jumper -cpus $MGC_cpus

    if {$MGC_fix_antenna_use_diodes eq true} {
	if {$MGC_fix_antenna_diodes != ""} {
	    config_antenna -diodes $MGC_fix_antenna_diodes
	}
	fix_antenna -method diode -finish all
    }
}

## Check if design is DRC clean before starting chip finishing
set MGC_num_drc_errors_threshold 100    ; # If number of DRC errors exceeds this threshold the chip finishing steps will not be performed
check_drc
set num0 [llength [get_objects -type error -filter @category==drc -quiet true]]
set skip_chip_finishing false
if { $num0 > $MGC_num_drc_errors_threshold } {
    fk_msg -type info "Number of DRC (including antenna) errors is too high ($num0 > $MGC_num_drc_errors_threshold). Chip finishing steps will be skipped \n"
    set skip_chip_finishing true
}

## Place Filler
set MGC_insert_filler_cells true     ; # true|false

if { $skip_chip_finishing == false && $MGC_insert_filler_cells eq true} {
    # only needed for advanced nodes 
    #config_place_detail -name honor_lib_cell_edge_spacing -value true
    set_property -objects [get_lib_cells -filter @is_filler] -name is_dont_use -value true
    if {[llength $MGC_filler_lib_cells] == 0} {
        set lc_list [get_lib_cells -filter @is_filler]
        if {[llength $lc_list] == 0} {
	    fk_msg -type error "Could not find any lib cells marked as filler cells.  No fillers inserted.\n"
        } else {
            set_property -objects $lc_list -name is_dont_use -value false
	    fk_msg -type info "Placing filler cells using all lib cells marked as fillers: $lc_list\n"
	    place_filler_cells -cpus $MGC_cpus -lib_cells $lc_list -respect_blockages $MGC_filler_respect_blockages
        }
    } elseif {[llength $MGC_filler_lib_cells] == 1} {
        set lc_list [get_lib_cells -filter @is_filler -pattern $MGC_filler_lib_cells]
        if {[llength $lc_list] == 0} {
	    fk_msg -type error "Could not find any filler lib cells matching pattern $MGC_filler_lib_cells.  No fillers inserted.\n"
        } else {
	    set_property -objects $lc_list -name is_dont_use -value false
	    fk_msg -type info "Placing filler cells using lib cells: $lc_list\n"
	    place_filler_cells -cpus $MGC_cpus -lib_cells $lc_list -respect_blockages $MGC_filler_respect_blockages
        }
    } else {
        set lc_string [join $MGC_filler_lib_cells]
        set tempvar ""
        if {[string is integer -strict [lindex $lc_string 1]]} {
            for {set x 0} {$x < [llength $lc_string]} {incr x 2} {
              set fcpattern [lindex $lc_string $x]
              set fcpercent [lindex $lc_string $x+1]
              lappend tempvar "$fcpattern $fcpercent"
            }
            set MGC_filler_lib_cells $tempvar
	    # Place filler cells by using the percentage-based algorithm
	    set fill_groups {}
	    foreach filler_group $MGC_filler_lib_cells {
	        set filler_libcells [lindex $filler_group 0]
	        set filler_percentage [lindex $filler_group 1]
	        set filler_groupname [regsub -all {[*?]} $filler_libcells ""]
	        set_property -objects [get_lib_cells -filter is_filler -pattern $filler_libcells] -name is_dont_use -value false
	        create_filler_set -name FS_$filler_groupname -lib_cells [get_lib_cells -filter is_filler -pattern $filler_libcells]
	        lappend fill_groups FS_$filler_groupname $filler_percentage
	    }
            fk_msg -type info "Placing filler cells using filler sets."
            report_filler_sets
            puts "Filler set percentages:"
            for {set x 0} {$x < [llength $fill_groups]} {incr x 2} {
                puts "\t[lindex $fill_groups $x] = [lindex $fill_groups $x+1]%"
            }
            puts ""
	    place_filler_cells -filler_set_prefix true -filler_set_percentages $fill_groups -cpus $MGC_cpus -respect_blockages $MGC_filler_respect_blockages
        } else {
            set lc_list [get_lib_cells -filter @is_filler -pattern $MGC_filler_lib_cells]
            if {[llength $lc_list] == 0} {
                fk_msg -type error "Could not find any filler lib cells matching pattern $MGC_filler_lib_cells.  No fillers inserted.\n"
            } else {
                set_property -objects $lc_list -name is_dont_use -value false
                fk_msg -type info "Placing filler cells using lib cells: $lc_list\n"
                place_filler_cells -cpus $MGC_cpus -lib_cells $lc_list -respect_blockages $MGC_filler_respect_blockages
            }
        }
    }
    
    ## Check for unfilled gaps.  
    ## This has a dependency on how fill was inserted under blockages.
    fk_msg -type info "Checking for unfilled gaps after filler cell insertion"
    if { $MGC_filler_respect_blockages == "hard" } {
            check_unfilled_gaps -include_gaps_under_blockage false
       } elseif { $MGC_filler_respect_blockages == "all" } {
            check_unfilled_gaps -include_gaps_under_blockage false
       } elseif { $MGC_filler_respect_blockages == "none" } {
            check_unfilled_gaps -include_gaps_under_blockage true
       }
         
    ## Check for any new DRC issues and fix them
    check_drc
    set num1 [llength [get_objects -type error -filter @category==drc]]
    if { $num1 } {
	if { $num1 > $num0 } {
	    fk_msg -type info "Number of DRC errors increased after filler cell insertion ($num1 > $num0). Running DRC clean-up \n"
	} else {
	    fk_msg -type info "Running DRC clean-up for remaining $num1 errors.\n"
	}
	clean_drc
	run_route_timing -mode repair -cpus $MGC_cpus -user_params "-drc_effort high -drc_accept number -dp_local_effort high"
	check_drc
	set num2 [llength [get_objects -type error -filter @category==drc]]
	if { $num2 } {
	    fk_msg -type info "$num2 DRC errors remain.\n"
	}
    }
}
## Insert Metal Fill
if { $skip_chip_finishing == false && $MGC_skip_metal_fill == false} {
     fk_msg -type info "Inserting metal fill"
     insert_metal_fill
}

## Write out data
set design [current_design]
set dataDir output

if { [info exists MGC_tanner_flow] && $MGC_tanner_flow eq "true"} {
    # Write output data to EXPORT directory
    write_verilog -file results/[current_design].v -bus_aware true
    write_def -skip regions -all_vias -db_units 1000 -file results/routed.def -prefix_special_characters false
    set corners [get_corners -filter enable]
    set modes [get_modes -filter enable]
    foreach_in_collection el $corners {
	foreach el1 $modes {
	    write_sdf -corner $el -mode $el1 -file ./results/SDF_[current_design]_${el}_${el1}.sdf -skip_backslash true
	}
    }
    # Exporting SPEF
    foreach el $corners {
	write_spef -corner $el  -file ./results/SPEF_[current_design]_${el}.spef -coupling
    }
} else {
    write_verilog -file $dataDir/${design}.v.gz
    write_def -file $dataDir/${design}.def.gz
    write_lef -file $dataDir/${design}.lef.gz -lib_cells [get_lib_cells -of_objects [get_top_partition]]
}

# Export GDS
#we might need resolution 5.0:
#config_write_stream -resolution 5.0
if { $MGC_gds_layer_map_file != "" } {
    source $MGC_gds_layer_map_file
    write_stream -format gds -file $dataDir/${design}.gds
} elseif { $MGC_gds_layer_map_file == "" } {
    fk_msg -type warning "No GDS layer-map file specified in flow variable MGC_gds_layer_map_file.  GDS will not be written"
} 

# Save db
if { [file exists dbs/libs.db] } {
    ## split_db is true
    write_db -data design -file dbs/export.db
} else {
    write_db -data all -file dbs/export.db
}
nrf_utils::write_reports $MGC_flowStage reports 100

# Propagate power and grounds and output power netlist

if { [info exists MGC_no_exit] && $MGC_no_exit eq "true" } {
    fk_msg -type info "Because Nitro is not being exited, supply nets are not propagated and power netlist is not output by default.\n"
} else {
    propagate_power_and_ground_nets
    write_verilog -file $dataDir/${design}.power.v.gz -power true -well_connections true
#    exit
}

