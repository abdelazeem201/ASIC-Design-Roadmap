################################################################################
start_profile
set timing_update_status_level high


################################################################################
set sh_source_emits_line_numbers E
set sh_continue_on_error true


#################################################################################
# PrimeTime Script
# Script: pt.tcl
# Version: O-2018.06-SP2 (September. 28, 2018)
# Copyright (C) 2022-2024 abdelazeem.
#################################################################################


##################################################################
#    Source common and pt_setup.tcl File                         #
##################################################################

# Allow source to use search_path
set sh_source_uses_search_path true 
source ./common_setup.tcl
source ./pt_setup.tcl


##################################################################
#    Search Path, Library and Operating Condition Section        #
##################################################################


set report_default_significant_digits 3 ;
set sh_source_uses_search_path true 
set search_path " $search_path" ;


##################################################################
#    Netlist Reading Section                                     #
##################################################################

set link_path " $link_path"

read_verilog $NETLIST_FILES

current_design $DESIGN_NAME 
link_design -verbose 

##################################################################
#    Back Annotation Section                                     #
##################################################################

read_parasitics  $PARASITIC_FILES 

report_annotated_parasitics -check > $REPORTS_DIR/rap.report


##################################################################
#    Reading Constraints Section                                 #
##################################################################
if  {[info exists CONSTRAINT_FILES]} {
        foreach constraint_file $CONSTRAINT_FILES {
                if {[file extension $constraint_file] eq ".sdc"} {
                        read_sdc -echo $constraint_file
                } else {
                        source -echo $constraint_file
                }
        }
}


##################################################################
#    Clock Tree Synthesis Section                                #
##################################################################

set_propagated_clock [all_clocks] 


##################################################################
#    Update_timing and check_timing Section                      #
##################################################################

update_timing -full

# Ensure design is properly constrained
check_timing -verbose > $REPORTS_DIR/ct.report

##################################################################
#    Report_timing Section                                       #
##################################################################
# Report Timing
report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net -sign 4 > $REPORTS_DIR/rt.report
report_clock -skew -attribute > $REPORTS_DIR/rc.report 
report_analysis_coverage > $REPORTS_DIR/rac.report


#################################################################
#    Save Session                                               #
#################################################################










##########################################################################
stop_profile
save_session my_savesession
print_message_info
exit
##########################################################################
