##########################################################################################
# common variables
# Script: common_setup.tcl
# Version: O-2018.06 (Oct. 3, 2022)
# Copyright (C) 2022, 2024 abdelazeem.
##########################################################################################

set DESIGN_NAME                   "ORCA"  ;#  The name of the top-level design

set DESIGN_REF_DATA_PATH          "../ref"  ;#  Absolute path prefix variable for library/design data.
                                        #  Use this variable to prefix the common absolute path to 
                                        #  the common variables defined below.
                                        #  Absolute paths are mandatory for hierarchical RM flow.

##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

set ADDITIONAL_SEARCH_PATH        "$DESIGN_REF_DATA_PATH/design_data  $DESIGN_REF_DATA_PATH/libs  $DESIGN_REF_DATA_PATH/scripts  $DESIGN_REF_DATA_PATH/tcl_procs ./pt_scripts"   ; #  Additional search path to be added to the default search path

set TARGET_LIBRARY_FILES          "sc_max.db" ;#  Target technology logical libraries


set ADDITIONAL_LINK_LIB_FILES     "io_max.db \
                                   special.db \
                                   mem_max.db " ;#  Extra link logical libraries not included in TARGET_LIBRARY_FILES



set MIN_LIBRARY_FILES             "";#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

set MW_REFERENCE_LIB_DIRS         "" ;#  Milkyway reference libraries

set MW_REFERENCE_CONTROL_FILE     ""  ;#  Reference Control file to define the MW ref libs

set TECH_FILE                     "${DESIGN_REF_DATA_PATH}/libs/tech/cb13_6m.tf"  ;#  Milkyway technology file


set MAP_FILE                      "${DESIGN_REF_DATA_PATH}/libs/tlup/cb13_6m.map"  ;#  Mapping file for TLUplus

set TLUPLUS_MAX_FILE              "${DESIGN_REF_DATA_PATH}/libs/tlup/cb13_6m_max.tluplus"  ;#  Max TLUplus file

set TLUPLUS_MIN_FILE              "${DESIGN_REF_DATA_PATH}/libs/tlup/cb13_6m_min.tluplus"  ;#  Min TLUplus file

set MW_POWER_NET                  "VDD" ;#
set MW_POWER_PORT                 "VDD" ;#
set MW_GROUND_NET                 "VSS" ;#
set MW_GROUND_PORT                "VSS" ;#

set MIN_ROUTING_LAYER             ""   ;# Min routing layer
set MAX_ROUTING_LAYER             "METAL2"   ;# Max routing layer


##########################################################################################
# Multi-Voltage Common Variables
#
# Define the following MV common variables for the RM scripts for multi-voltage flows.
# Use as few or as many of the following definitions as needed by your design.
##########################################################################################

set PD1                          ""           ;# Name of power domain/voltage area  1
set PD1_CELLS                    ""           ;# Instances to include in power domain/voltage area 1
set VA1_COORDINATES              {}           ;# Coordinates for voltage area 1
set MW_POWER_NET1                "VDD1"       ;# Power net for voltage area 1
set MW_POWER_PORT1               "VDD"        ;# Power port for voltage area 1

set PD2                          ""           ;# Name of power domain/voltage area  2
set PD2_CELLS                    ""           ;# Instances to include in power domain/voltage area 2
set VA2_COORDINATES              {}           ;# Coordinates for voltage area 2
set MW_POWER_NET2                "VDD2"       ;# Power net for voltage area 2
set MW_POWER_PORT2               "VDD"        ;# Power port for voltage area 2

set PD3                          ""           ;# Name of power domain/voltage area  3
set PD3_CELLS                    ""           ;# Instances to include in power domain/voltage area 3
set VA3_COORDINATES              {}           ;# Coordinates for voltage area 3
set MW_POWER_NET3                "VDD3"       ;# Power net for voltage area 3
set MW_POWER_PORT3               "VDD"        ;# Power port for voltage area 3

set PD4                          ""           ;# Name of power domain/voltage area  4
set PD4_CELLS                    ""           ;# Instances to include in power domain/voltage area 4
set VA4_COORDINATES              {}           ;# Coordinates for voltage area 4
set MW_POWER_NET4                "VDD4"       ;# Power net for voltage area 4
set MW_POWER_PORT4               "VDD"        ;# Power port for voltage area 4
