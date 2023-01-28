set unq_input_list [all_inputs]
foreach_in_collection unq_clock_element [all_clocks] {
     set unq_clock_name [get_port  $unq_clock_element]
     set unq_input_list [remove_from_collection $unq_input_list $unq_clock_name]
}
group_path -name f2f -from [all_registers]  -to [all_registers] -critical_range 0.7
group_path -name i2f -from $unq_input_list -to [all_registers] -critical_range 0.7
group_path -name f2o -from [all_registers]  -to [all_outputs]   -critical_range 0.7
group_path -name i2o -from $unq_input_list -to [all_outputs]   -critical_range 0.7
