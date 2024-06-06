#!/usr/bin/env wish

# Written by Ahmed Abdelazeem
# March 11, 2024
# Updated to cover more LEF cases
# July 1, 2024
# A TCL script processes a technology file (.tf) and an LEF (Library Exchange Format) file to generate a mapping between layers defined in these files.

set EXPECTED_COMMAND_ARGS 2

if {[llength $argv] < $EXPECTED_COMMAND_ARGS} {
    puts "Usage: lef_layer_tf_number_map.tcl Tech_file_name.tf Lef_file_name.lef"
    exit 1
} else {
    set tech_file [lindex $argv 0]
    set lef_file [lindex $argv 1]
    set tmp_s1 [regsub {.tf} $tech_file {_tf}]
    set tmp_s2 [regsub {.lef} $lef_file {_lef}]
    set lef_tf_map_file "${tmp_s2}_${tmp_s1}.map"
    set lef_tf_log_file "${tmp_s2}_${tmp_s1}.log"
}

set tech_file_id [open $tech_file r]
if {$tech_file_id == ""} {
    puts "Can't open $tech_file"
    exit 1
}

set lef_file_id [open $lef_file r]
if {$lef_file_id == ""} {
    puts "Can't open $lef_file"
    exit 1
}

set lef_tf_log_file_id [open $lef_tf_log_file w]
if {$lef_tf_log_file_id == ""} {
    puts "Can't open $lef_tf_log_file"
    exit 1
}

set lef_tf_map_file_id [open $lef_tf_map_file w]
if {$lef_tf_map_file_id == ""} {
    puts "Can't open $lef_tf_map_file"
    exit 1
}

proc print_log {message} {
    puts $message
    puts $::lef_tf_log_file_id $message
}

proc print_map {message} {
    puts $message
    puts $::lef_tf_map_file_id $message
}

print_log "\n*** Beginning to process $tech_file tech file***\n"

set i 0
array set tf_layerMaskNames {}
array set tf_layerMaskLayerNumber {}
array set tf_layerName {}

set processing_tf_layer 0
set found_maskName 0
set tf_masks 0

while {[gets $tech_file_id line] != -1} {
    regsub -all {[\[\]]} $line {} line
    regsub -all {\{\}} $line {} line
    regsub -all {\[\]} $line {} line
    regsub -all {\{\}} $line {} line
    regsub -all {"} $line {} line
    regsub -all {;} $line {} line
    regsub -all {\;} $line {} line
    regsub -all {[()]}} $line {} line

    if {[regexp {^[lL][aA][yY][eE][rR][\s]+\"([\w\W]+)\"[\s]+\{.*$} $line match tf_layer_name]} {
        if {$processing_tf_layer == 0} {
            set processing_tf_layer 1
            print_log "\nBeginning to process $tf_layer_name layer...\n"
        }
    } elseif {[regexp {^[\s]*\}.*$} $line]} {
        if {$processing_tf_layer == 1} {
            if {$found_maskName == 1} {
                set tf_layerMaskNames($tf_masks) $tf_maskName
                set tf_layerMaskLayerNumber($tf_maskName) $tf_layerNumber
                set tf_layerName($tf_maskName) $tf_layer_name

                incr tf_masks
                set found_maskName 0
            }
            print_log "Completed the processing of $tf_layer_name layer.\n"
            set processing_tf_layer 0
        }
    } elseif {[regexp {^[\s]*layerNumber[\s]*\=[\s]*([\d]+).*} $line match tf_layerNumber]} {
        set tf_layerNumber [lindex $match 1]
        print_log "Found the layerNumber $tf_layerNumber for the $tf_layer_name!\n"
    } elseif {[regexp {^[\s]*maskName[\s]*\=[\s]*\"([\w]+)\".*} $line match tf_maskName]} {
        set tf_maskName [lindex $match 1]
        set found_maskName 1
        print_log "Found the maskName $tf_maskName for the $tf_layer_name!\n"
    }
    incr i
}

print_log "\n*** Beginning to process $lef_file LEF file***\n"

set lef_masks 0
set processing_lef_layer 0
set lef_prev_layerTYPE ""
set metal_index 0

while {[gets $lef_file_id line] != -1} {
    regsub -all {[\[\]]} $line {} line
    regsub -all {\{\}} $line {} line
    regsub -all {\[\]} $line {} line
    regsub -all {\{\}} $line {} line
    regsub -all {"} $line {} line
    regsub -all {;} $line {} line
    regsub -all {\;} $line {} line
    regsub -all {[()]}} $line {} line

    if {[regexp {^LAYER[\s]+([\w]+)[\s]*$} $line match lef_layer_name]} {
        if {$processing_lef_layer == 0} {
            set processing_lef_layer 1
            print_log "\nBeginning to process $lef_layer_name layer...\n"
        }
    } elseif {[regexp {^END[\s]+[\w]+[\s]*$} $line]} {
        if {$processing_lef_layer == 1} {
            set lef_derivedmaskName ""
            if {($lef_layerTYPE eq "MASTERSLICE") && ($lef_masks == 0)} {
                set lef_derivedmaskName "poly"
            } elseif {($lef_layerTYPE eq "CUT") && ($lef_prev_layerTYPE eq "MASTERSLICE")} {
                set lef_derivedmaskName "polyCont"
            } elseif {($lef_layerTYPE eq "ROUTING")} {
                if {$metal_index == 0} {incr metal_index}
                else {incr metal_index}
                set lef_derivedmaskName "metal$metal_index"
            } elseif {($lef_layerTYPE eq "CUT") && ($lef_prev_layerTYPE ne "MASTERSLICE")} {
                set lef_derivedmaskName "via$metal_index"
            } elseif {($lef_layerTYPE eq "OVERLAP")} {
                print_log "Skipping the OVERLAP Layer...\n"
            } else {
                print_log "Can not process due to issue...\n"
                exit 1
            }

            if {$lef_derivedmaskName ne ""} {
                set lef_derivedlayerNumber $tf_layerMaskLayerNumber($lef_derivedmaskName)

                set lef_layerDerivedMaskNames($lef_masks) $lef_derivedmaskName
                set lef_layerDerivedMaskNames($lef_masks) $lef_derivedmaskName
                set lef_layerDerivedMaskLayerNumber($lef_derivedmaskName) $lef_derivedlayerNumber
                set lef_layerName($lef_derivedmaskName) $lef_layer_name
                incr lef_masks
            }
            print_log "Completed the processing of $lef_layer_name layer.\n"
            set processing_lef_layer 0
            set lef_prev_layerTYPE $lef_layerTYPE
        }
    } elseif {[regexp {^[\s]*TYPE[\s]+([\w]+)[\s]*\;.*$} $line match lef_layerTYPE]} {
        set lef_layerTYPE [lindex $match 1]
        print_log "Found the TYPE $lef_layerTYPE for the $lef_layer_name!\n"
    }
    incr i
}

print_log "\n*** Printing the map file between $lef_file and $tech_file ***\n"
for {set j 0} {$j < $lef_masks} {incr j} {
    print_map "$lef_layerName($lef_layerDerivedMaskNames($j))"
    print_map " $lef_layerDerivedMaskLayerNumber($lef_layerDerivedMaskNames($j))\n"
}

close $lef_tf_map_file_id

proc print_log {message} {
    puts $message
    puts $::lef_tf_log_file_id $message
}

proc print_map {message} {
    puts $message
    puts $::lef_tf_map_file_id $message
}
