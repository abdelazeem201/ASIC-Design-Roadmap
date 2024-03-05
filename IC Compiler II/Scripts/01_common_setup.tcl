##############################################################
# Common design settings
# Created by Ahmed Abdelazeem
##############################################################
set_host_options -max_cores 16
set_app_var sh_continue_on_error true
### design information
set DESIGN_NAME  		  "pit_top";

set Design_LIBRARY                "/home/abdelazeem/Desktop/Abdelazeem/PGDip/Project/StandardCell/NangateOpenCellLibrary_PDKv1_3_v2010_12";
set DESIGN_REF_PATH		  "$Design_LIBRARY/lib/Front_End/Liberty/NLDM"
set DESIGN_REF_TECH_PATH    	  "$Design_LIBRARY/tech/techfile/milkyway"
set_app_var search_path           "$Design_LIBRARY $DESIGN_REF_PATH $DESIGN_REF_TECH_PATH"
set NDM_REFERENCE_LIB_DIRS  	  "$Design_LIBRARY/CLIBS/NangateOpenCellLibrary_ss0p95v125c.ndm \
				   $Design_LIBRARY/CLIBS/NangateOpenCellLibrary_ff1p25v0c.ndm"

set TECH_FILE                     "${DESIGN_REF_TECH_PATH}/FreePDK45_10m.tf" 
set MAP_FILE                      "$Design_LIBRARY/tech/rcxt/FreePDK45_10m.map"  ;#  Mapping file for TLUplus
set TLUPLUS_MAX_FILE              "$Design_LIBRARY/tech/rcxt/FreePDK45_10m_Cmax.tlup"  ;#  Max TLUplus file
set TLUPLUS_MIN_FILE              "$Design_LIBRARY/tech/rcxt/FreePDK45_10m_Cmin.tlup"  ;#  Min TLUplus file
set GDS_MAP_FILE		  "$Design_LIBRARY/tech/strmout/FreePDK45_10m_gdsout.map"	
set STD_CELL_GDS          	  "$Design_LIBRARY/lib/Back_End/gds/NangateOpenCellLibrary.gds"

set ROUTING_LAYER_DIRECTION_OFFSET_LIST "{metal1 horizontal} {metal2 vertical} {metal3 horizontal} {metal4 vertical} {metal5 horizontal} {metal6 vertical} {metal7 horizontal} {metal8 vertical} {metal9 horizontal} {metal10 vertical}"
set MIN_ROUTING_LAYER		"metal1"	;# Min routing layer name; normally should be specified; otherwise tool can use all metal layers
set MAX_ROUTING_LAYER		"metal10"	;# Max routing layer name; normally should be specified; otherwise tool can use all metal layers

set NDM_POWER_NET                "VDD" ;#
set NDM_POWER_PORT               "VDD" ;#
set NDM_GROUND_NET               "VSS" ;#
set NDM_GROUND_PORT              "VSS" ;#


set SYN_DIR                      "/home/abdelazeem/Desktop/Abdelazeem/PGDip/Project/syn"
set VERILOG_NETLIST_FILES	 "$SYN_DIR/output/${DESIGN_NAME}.v"	;# Verilog netlist files; 
set SDC_CONSTRAINTS 		 "$SYN_DIR/output/${DESIGN_NAME}.sdc"	
