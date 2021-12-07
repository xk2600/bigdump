#!/usr/bin/env tclsh

namespace eval tool {

  namespace export eval export
  namespace ensemble create

  variable commandProcessor [dict create {*}{
    help {}
    exports {}
  }]

  # print syntax 
  proc syntax {} {
    uplevel #0 {puts -nonewline "usage: $argv0 command \[args\]\n\n"}
  }

  # no sense in even continuing this, if we don't have argc and argv0
  if {[uplevel #0 {set argc}] < 1} {
    syntax
    exit
  }

  # internal - called in switch statement where no match (error)
  proc UNKNOWN_COMMAND {command} {
    variable commandProcessor
    set exports [dict keys $commandProcessor exports]
    set errmsg {unknown command "%s" must be %s}
    set err [format $errmsg $command [linsert [join $exports ", "] end-1 or]]
    puts stderr $err
    syntax
    exit
  }

  # public - adds exports proc to 'commandProcessor exports' dict
  proc export {args} {
    if {[llength $args] == 0} {
      return -code error "wrong # args: must be tool forget ?...varname?"
    }
    variable commandProcessor
    foreach command $args {
      set callback [format {namespace origin %s} $command]
      if {![dict exists $commandProcessor exports $command]} {
        dict lappend commandProcessor exports $command [uplevel #0 $callback]
      }
    }
  }

  proc eval {args} {
    variable commandProcessor
    if {[llength $args] > 1} {
      set args [lassign $args command]
    } else {
      set args [uplevel {list $argc $argv0 {*}$argv}]
      set args [lassign $args argc argv0 command]
      set argv0 [split $argv0 {/}]
    }
    
    if {[dict exists $commandProcessor exports $command]} {
      set target [dict get $commandProcessor exports $command]

      if {[catch {$target {*}$args} err]} {
        puts $err
        syntax
      } 
      # success
    } else {

      UNKNOWN_COMMAND $target
    }
  }
}


########## TEST #######################################################

namespace eval ::index { 
  namespace export hello test stats
  namespace ensemble create 
}

proc ::index::hello {} {
  puts "world"
}

proc ::index::test {} {
  puts "tested!"
}

proc ::index::stats {} {
  # find disk usage
  set fd [open $index r]
  while {[llength [gets $fd]] > 0} {
    count 
  }
}

namespace eval ::rip {} {
  namespace export test
  namespace ensemble create
}

proc ::rip::test {} {
}

tool export index
tool export rip


tool eval


