##############################################################
# MCMM design settings
# Created by Ahmed Abdelazeem
##############################################################
########################################
## Variables
########################################
## Scenario constraints; expand the section as needed
set SDC_CONSTRAINTS 		 "$SYN_DIR/output/${DESIGN_NAME}.sdc"

########################################
## Create modes, and corners
########################################
remove_modes -all; 
remove_corners -all; 
remove_scenarios -all

create_corner slow
create_corner fast

create_mode func
current_mode func
##############################################################################################
# The following is a sample script to read two TLU+ files, 
# which you can expand to accomodate your design.
##############################################################################################

read_parasitic_tech \
	-tlup $TLUPLUS_MAX_FILE \
	-layermap $MAP_FILE \
	-name tlup_max

read_parasitic_tech \
	-tlup $TLUPLUS_MIN_FILE \
	-layermap $MAP_FILE \
	-name tlup_min
set_parasitics_parameters \
	-early_spec tlup_min \
	-late_spec tlup_min \
	-corners {fast}

set_parasitics_parameters \
	-early_spec tlup_max \
	-late_spec tlup_max \
	-corners {slow}	
########################################
## Create scenario
########################################
create_scenario -mode func -corner fast -name func_fast
create_scenario -mode func -corner slow -name func_slow

current_scenario func_fast
source $SDC_CONSTRAINTS

current_scenario func_slow
source $SDC_CONSTRAINTS
########################################
## Configure analysis settings for scenarios
########################################
remove_duplicate_timing_contexts
