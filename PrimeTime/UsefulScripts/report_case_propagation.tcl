# report_case_propagation.tcl - trace case analysis back to source(s)
# abdelazeem@synopsys.com
#
# v1.0  05/25/2024  abdelazeem
#  initial release
# v1.01 05/31/2024  abdelazeem
#  fix bug with parallel arcs between two pins

proc report_case_propagation {args} {
 parse_proc_arguments -args $args results

 set objects {}
 append_to_collection objects [get_pins -quiet $results(pins_ports)]
 append_to_collection objects [get_ports -quiet $results(pins_ports)]

 # make a list of startpoint contexts to queue up
 # (I use a flat context list instead of succumbing to the lure of recursion...)
 set queued_contexts {}
 foreach_in_collection object $objects {
  lappend queued_contexts [list $object 0]
 }

 array unset visited_from_pins
 array unset visited_pairs
 while {$queued_contexts ne {}} {

  # pop next to_pin off list
  set context [lindex $queued_contexts 0]
  foreach {to_pin indent_level} $context {}
  set queued_contexts [lrange $queued_contexts 1 end]
  set to_pin_name [get_object_name $to_pin]

  # get list of valid from_pins with case values
  set valid_from_pins {}
  if {[set user_case_value [get_attribute -quiet $to_pin user_case_value]] eq {}} {
   foreach_in_collection arc [get_timing_arcs -quiet -to $to_pin] {
    if {[set from_pin [filter_collection [get_attribute $arc from_pin] {defined(case_value)}]] ne {}} {
     append_to_collection -unique valid_from_pins $from_pin
    }
   }
  }

  # from the valid from_pins, get list of the from_pins for all the
  # unvisited backwards *arcs* ending at this pin
  # (the visited_pairs() array contains all the backwards arcs we've been down before)
  set unvisited_from_pins {}
  foreach_in_collection from_pin $valid_from_pins {
   set from_pin_name [get_object_name $from_pin]
   if {![info exists visited_pairs([list $from_pin_name $to_pin_name])]} {
    append_to_collection unvisited_from_pins $from_pin
   }
  }

  # print information about this to_pin
  switch [get_attribute $to_pin object_class] {
   pin {
    if {[set ref_info [get_object_name [get_lib_cells -quiet -of [get_cells -quiet -of $to_pin]]]] eq {}} {
     set ref_info [get_attribute [get_cells -quiet -of $to_pin] ref_name]
    }
   }
   port {set ref_info "[get_attribute $to_pin port_direction] port"}
  }
  if {[sizeof_collection $valid_from_pins] >= 1 && [sizeof_collection $unvisited_from_pins]==0} {
   # in this branch, we arrived at this to_pin but all backwards arcs have previously been visited
   set branch_info " (previously covered path)"
  } elseif {[sizeof_collection $valid_from_pins] > 1} {
   # multiple backwards arcs exist, so there are multiple branches to trace back
   set branch_info " (branch [expr {1+[sizeof_collection $valid_from_pins]-[sizeof_collection $unvisited_from_pins]}] of [sizeof_collection $valid_from_pins] follows)"
  } else {
   # just a single unambiguous path to trace back
   set branch_info {}
  }
  if {$user_case_value ne {}} {
   set case_info "user-defined case=$user_case_value"
  } else {
   set case_info "case=[get_attribute -quiet $to_pin case_value]"
  }
  echo "[string repeat { } $indent_level][get_object_name $to_pin] ($ref_info) $case_info${branch_info}"

  # restart loop with next to_pin context if there's nothing to trace back
  # (nothing to queue up)
  if {$unvisited_from_pins eq {}} {
   continue
  }

  # first, grab the first from_pin on the list
  set from_pin [index_collection $unvisited_from_pins 0]
  set from_pin_name [get_object_name $from_pin]
  set unvisited_from_pins [remove_from_collection $unvisited_from_pins $from_pin]

  # if there are any additional remaining from_pins, queue *this* to_pin up again
  # so that we can trace back those other branches too
  if {$unvisited_from_pins ne {}} {
   set queued_contexts [linsert $queued_contexts 0 [list $to_pin $indent_level]]
  }

  # now, push our first unvisited from_pin onto the list of to_pins to visit next
  # (this moves us backwards down this path, and the fact that we push it last
  # causes the depth-first backtrace)
  if {[sizeof_collection $valid_from_pins] > 1} {
   incr indent_level
  }
  set queued_contexts [linsert $queued_contexts 0 [list $from_pin $indent_level]]

  # mark this arc as visited (so we never propagate past it in the future)
  set visited_pairs([list $from_pin_name $to_pin_name]) 1
 }

 echo ""
}

define_proc_attributes report_case_propagation \
 -info "trace case analysis back to source(s)" \
 -define_args \
 {
  {pins_ports {pin(s)/port(s) where case value is present} pins_ports string required}
 }

