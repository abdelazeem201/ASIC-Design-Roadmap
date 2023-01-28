read_lef -file /pdk/180nm/stdlib/fs120/tech_data/lef/tsl180l4.lef
read_lef -file /pdk/180nm/stdlib/fs120/lef/tsl18fs120_scl.lef
read_lib -name_prefix "ptf" -file /pdk/180nm/design_kit/mentor/RCE_TS18SL_SCL_STAR_RCXT_4M1L_TYP.ptf
read_lib -name_prefix "ss" -file /pdk/180nm/stdlib/fs120/liberty/lib_flow_ss/tsl18fs120_scl_ss.lib
read_lib -name_prefix "ff" -file /pdk/180nm/stdlib/fs120/liberty/lib_flow_ff/tsl18fs120_scl_ff.lib
set RC1_process [get_objects process_lib *ptf*] 
# write_db -data lib -file dbs/libs.db
set_analysis_corner -corner slow -enable false
set_analysis_corner -corner fast -enable false
set_analysis_corner -corner slow -enable true -setup true -hold false -crpr setup_hold -library [get_objects electrical_lib *ss*] -process_tech $RC1_process
report_analysis_corner
read_verilog /scratch/hcl/puru/mentor/oasys/fpu.v
read_constraints /scratch/hcl/puru/mentor/oasys/fpu.sdc 
current_design
# write_db import_design.db
##
create_chip -aspect 1.0 -utilization 50 -core_site CoreSite -orient north -double_backed false  -gap 11200a 
create_tracks
trim_rows
#
#check_route_power -check pg_nets
create_power_domain -domain primary -include_scope true
create_supply_net -net_name VSS -domain primary -power_net false
create_supply_net -net_name VDD -domain primary -power_net true
set_domain_supply_net -domain primary -primary_power_net VDD -primary_ground_net VSS
#get_property [get_objects -type power_domain]
#
config_units -value_type distance -units micro
#
create_pin_group -name grp1 -pins [get_ports -pattern "get_result[*]"]
create_pin_group -name grp2 -pins [get_ports -pattern "_start_fsr[*]"] 
create_pin_group -name grp3 -pins [get_ports -pattern "_start_opcode[*]"] 
create_pin_group -name grp4 -pins [get_ports -pattern "_start_funct7[*]"] 
create_pin_group -name grp5 -pins [get_ports -pattern "_start_funct3[*]"]
create_pin_group -name grp6 -pins [get_ports -pattern "_start_operand3[*]"] 
create_pin_group -name grp7 -pins [get_ports -pattern "_start_operand2[*]"]
create_pin_group -name grp8 -pins [get_ports -pattern "_start_operand1[*]"]

set_pin_group -pin_group grp1 -edge_index 0 -layers M3 -from 200u -to 270u -order_type clockwise
set_pin_group -pin_group grp2 -edge_index 0 -layers M3 -from 300u -to 320u -order_type clockwise
set_pin_group -pin_group grp3 -edge_index 0 -layers M3 -from 400u -to 410u -order_type clockwise
set_pin_group -pin_group grp4 -edge_index 0 -layers M3 -from 500u -to 510u -order_type clockwise
set_pin_group -pin_group grp5 -edge_index 0 -layers M3 -from 550u -to 570u -order_type clockwise
set_pin_group -pin_group grp6 -edge_index 1 -layers M2 -from 500u -to 570u -order_type clockwise
set_pin_group -pin_group grp7 -edge_index 2 -layers M3 -from 500u -to 570u -order_type clockwise
set_pin_group -pin_group grp8 -edge_index 3 -layers M2 -from 500u -to 570u -order_type clockwise

 Do power mesh creation

 hfp_place_pins

 write_db -file fpu_fp.db

 run_place_timing
 run_place_timing -tns_local_opt true

 write_db -file fpu_place.db

 COMMENTS: Clock Tree Synthesis Steps
 route_global -grid small
 set_rcd_models -stage cts
 config_cts -min_route_layer M2 -buffers {bufbd2 bufbd3 bufbd4 bufbd7 bufbda bufbdf bufbdk} \
 -inverters {invbd2 invbd4 invbd7 invbda invbdf invbdk} -max_fanout 32 -max_skew 500p \
 -max_transition 300p -use_inverters false
 
 analyze_clocks -outfile autoCTS.tcl
 
 create_nondefault_rule -name NDR1 -lib {design} -min_metal_layer M2 -max_metal_layer TOP_M
 set_nondefault_rule -object NDR1 -hard_spacing false -spacing_threshold 5u
 set_nondefault_rule -object NDR1 -layers {M2 M3} -width 0.56u -spacing 0.56u -wire_spacing {to_wire}
 set_nondefault_rule -object NDR1 -layers {TOP_M} -width 0.88u -spacing 0.92u -wire_spacing {to_wire}
 set_cts_routing_rule -cts_spec CTS_CLK -nondefault_rule [get_objects nondef NDR1] -from_height 2
 create_cts_spec -name CTS_CLK -root [get_pin CLK] 
 check_cts_constraints 

 compile_cts -cts_spec CTS_CLK
 place_detail -driven_by timing
 optimize_clock_tree -modify_tree true -objective "wns tns"
 run_route_timing -mode clock
 report_cts
 report_clock_skews -worst 10

 COMMENTS:  post CTS Steps
 run_prp_flow -step post_cts

 COMMENTS: Routing
 run_route_timing

