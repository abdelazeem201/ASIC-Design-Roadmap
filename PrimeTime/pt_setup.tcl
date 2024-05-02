

### pt_setup.tcl file              ###




### Start of PrimeTime Runtime Variables ###


##########################################################################################
# PrimeTime Variables PrimeTime script
# Script: pt_setup.tcl
# Version: O-2018.06-SP2 (April. 28, 2024)
# Copyright (C) 2022-2024 abdelazeem.
##########################################################################################


######################################
# Report and Results directories
######################################


set REPORTS_DIR "reports"
file mkdir $REPORTS_DIR


######################################
# Library & Design Setup
######################################


### Mode : Generic

set search_path ". $ADDITIONAL_SEARCH_PATH $search_path"
set target_library $TARGET_LIBRARY_FILES
set link_path "* $target_library $ADDITIONAL_LINK_LIB_FILES"


# Provide list of  Verilog netlist file. It can be compressed ---example "A.v B.v C.v"
set NETLIST_FILES               "orca_routed.v.gz"

# DESIGN_NAME will be checked for existence from common_setup.tcl
if {[string length $DESIGN_NAME] > 0} {
} else {
set DESIGN_NAME                   ""  ;#  The name of the top-level design
}















######################################
# Back Annotation File Section
######################################

#PARASITIC Files --- example "top.sbpf A.sbpf" 
#The path (instance name) and name of the parasitic file --- example "top.spef A.spef" 
#Each PARASITIC_PATH entry corresponds to the related PARASITIC_FILE for the specific block"   
#For a single toplevel PARASITIC file please use the toplevel design name in PARASITIC_PATHS variable."   
set PARASITIC_PATHS	 "ORCA" 
set PARASITIC_FILES	 "ORCA.SPEF.gz" 



######################################
# Constraint Section Setup
######################################
# Provide one or a list of constraint files.  for example "top.sdc" or "clock.sdc io.sdc te.sdc"
set CONSTRAINT_FILES	 "var_Day1.tcl orca_pt_constraints.tcl"  














######################################
# End
######################################



### End of PrimeTime Runtime Variables ###
