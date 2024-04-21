set chip_top_left 5.0
set chip_bottom_right 270.0
set num_pads_per_side 7

set PWR_BUDGET  0.001
set VOLTAGE     0.88
# Define the number of VDD and VSS pads on each side


# Calculate the spacing between pads
set pad_spacing [expr {($chip_bottom_right - $chip_top_left) / ($num_pads_per_side + 1)}]  

# Output the VDD virtual pads
# VDD & VSS virtual pads

remove_virtual_pads -all
for {set i 1} {$i <= $num_pads_per_side} {incr i} {
	
    set x [expr {$chip_top_left + $i * $pad_spacing}]	
    set_virtual_pad -net VDD -layer M9 -coordinate [format {%.1f %.1f} $x $chip_top_left]
    set_virtual_pad -net VDD -layer M9 -coordinate [format {%.1f %.1f} $x $chip_bottom_right]
    set_virtual_pad -net VSS -layer M9 -coordinate [format {%.1f %.1f} $x $chip_top_left]
    set_virtual_pad -net VSS -layer M9 -coordinate [format {%.1f %.1f} $x $chip_bottom_right]

    set y [expr {$chip_top_left + $i * $pad_spacing}]
    set_virtual_pad -net VDD -layer M9 -coordinate [format {%.1f %.1f} $chip_top_left $y] 
    set_virtual_pad -net VDD -layer M9 -coordinate [format {%.1f %.1f} $chip_bottom_right $y] 
    set_virtual_pad -net VSS -layer M9 -coordinate [format {%.1f %.1f} $chip_top_left $y] 
    set_virtual_pad -net VSS -layer M9 -coordinate [format {%.1f %.1f} $chip_bottom_right $y]
}

 analyze_power_plan -power_budget $PWR_BUDGET -voltage $VOLTAGE -nets {VDD VSS} -use_terminals_as_pads
