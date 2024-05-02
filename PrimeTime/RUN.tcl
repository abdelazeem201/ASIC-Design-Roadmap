# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# PrimeTime STA run script for ORCA
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

########################
# Setup

source ./common_setup.tcl
source ./pt_setup.tcl

# Allow source to use search_path
set sh_source_uses_search_path true

# Do not allow black boxes for unresolved references
set link_create_black_boxes false


########################
# READ and LINK

read_verilog orca_routed.v.gz
link_design ORCA

read_parasitics ../ref/design_data/ORCA.SPEF.gz

########################
# Apply constraints

source -echo -verbose orca_pt_constraints.tcl
report_analysis_coverage

########################
# Save session

file delete -force orca_savesession
save_session orca_savesession

quit
