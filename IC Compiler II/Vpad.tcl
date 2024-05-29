set die_llx [lindex [lindex [ get_attribute [get_die_area] bbox] 0] 0]
set die_lly [lindex [lindex [ get_attribute [get_die_area] bbox] 0] 1]
set die_urx [lindex [lindex [ get_attribute [get_die_area] bbox] 1] 0]
set die_ury [lindex [lindex [ get_attribute [get_die_area] bbox] 1] 1]

for {set i "[expr $die_llx + 20]"} {$i < "[expr $die_urx - 40]"} {set i [expr $i + 80]} {
	set_virtual_pad -net VSS -coordinate [format {%.1f %.1f} $i $die_lly]
	set_virtual_pad -net VDD -coordinate [format {%.1f %.1f} [expr $i + 40] $die_lly]

	set_virtual_pad -net VSS -coordinate [format {%.1f %.1f}  $i $die_ury]
	set_virtual_pad -net VDD -coordinate [format {%.1f %.1f} [expr $i + 40] $die_ury]
}
for {set i "[expr $die_lly + 20]"} {$i < "[expr $die_ury - 40]"} {set i [expr $i + 80]} {
	set_virtual_pad -net VSS -coordinate [format {%.1f %.1f} $die_llx $i]
	set_virtual_pad -net VDD -coordinate [format {%.1f %.1f} $die_llx [expr $i + 40]]

	set_virtual_pad -net VSS -coordinate [format {%.1f %.1f} $die_urx $i]
	set_virtual_pad -net VDD -coordinate [format {%.1f %.1f} $die_urx [expr $i + 40] ]
}

analyze_power_plan -power_budget 250 -voltage 1.2 -nets {VDD VSS} -use_terminals_as_pads
