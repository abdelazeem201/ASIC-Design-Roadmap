# 02_preroute.tcl
set CHIP_LIB    "CHIP_LIB"
set TOP         "CHIP"
set SDC         "../design_data/CHIP.sdc"
set RPT_PATH    "../rpt/"
set PWR_NET_LYR [list M6 M5]
set POWER  "VDD"
set GROUND "VSS"
#======================================================================
# Connect I/O PAD to P/G Ring
#======================================================================
preroute_instances  -ignore_macros \
                    -ignore_cover_cells \
                -primary_routing_layer pin \
                -extend_for_multiple_connections \
                -extension_gap 16
#======================================================================
# Connect Block Ring to P/G Ring
#======================================================================
preroute_instances  -ignore_pads \
            -ignore_cover_cells \
            -primary_routing_layer pin
 
#preroute_instances -ignore_pads -ignore_cover_cells \
#                   -connect_instances specified \
#                   -macros $MEM -skip_bottom_side \
#                   -extension_gap 4
 
#==========================================
# Note :
# if you meet Double Via problem ( double via < 90% )  # File -> Task -> All Task
# cut_row -within {{1272.140 816.060} {1400.480 842.505}}
# cut_row -within {{1272.375 776.450} {1400.365 805.365}}
# cut_row -within {{183.110 797.725} {310.045 823.935}}
# cut_row -within {{181.700 756.355} {310.160 785.970}}
# create_power_straps -direction vertical -start_at 303.00 -nets {VDD VSS}  -layer M8 -width 4
# create_power_straps -direction vertical -start_at 1275.00 -nets {VDD VSS} -layer M8 -width 4
#======================================================================
# Preroute Std Cell Rail
#======================================================================
#set_route_zrt_common_options -freeze_layer_by_layer_name {{AP true}}   ; # don't use layer AP (metal 10) to avoid DRC violations
preroute_standard_cells -extend_for_multiple_connections \
                        -extension_gap 16 -connect horizontal \
                        -remove_floating_pieces \
                        -do_not_route_over_macros \
                        -fill_empty_rows \
                        -port_filter_mode off \
                        -cell_master_filter_mode off \
                        -cell_instance_filter_mode off \
                        -voltage_area_filter_mode off \
                        -route_type {P/G Std. Cell Pin Conn}
#======================================================================
# Create placement blockage
#======================================================================
#create_placement_blockage -coordinate {0.0 1.1} -name haha0 -type hadr -no_snap
#======================================================================
# Set PNET and Re-Compile
#   -complete : no std cell on power net
#   -partial : partial std cells on power net
#======================================================================
set_pnet_options -complete $PWR_NET_LYR
#set_pnet_options -partial $PWR_NET_LYR
create_fp_placement -timing_driven -congestion_driven -incremental all
derive_pg_connection -power_net $POWER -ground_net $GROUND -power_pin $POWER -ground_pin $GROUND
add_tap_cell_array -master_cell_name {FILLTIE4_A9TR} -distance 20 -no_tap_cell_under_layers {M1 M2} ; # insert well tap for TN40G
#=====================================================================
# Check clock constraints before CTS
#=====================================================================
read_sdc -echo -version Latest $SDC
report_clock > [format "%s%s%s" $RPT_PATH $TOP "_plan_clk.rpt"]
report_clock -skew > [format "%s%s%s" $RPT_PATH $TOP "_plan_clk_skew.rpt"]
#=====================================================================
# Check timing: if(slack is large)  modify design planning
#                 else keep going
#=====================================================================
set_zero_interconnect_delay_mode true
report_timing > [format "%s%s%s" $RPT_PATH $TOP "_plan_timing.rpt" ]
#set_ideal_network [get_ports se]
report_constraint -all > [format "%s%s%s" $RPT_PATH $TOP "_plan_clk_con.rpt" ]
set_zero_interconnect_delay_mode false
#=====================================================================
# Save Design
#=====================================================================
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"]
save_mw_cel -design [format "%s%s" $TOP ".CEL;1"] -as "preroute"
