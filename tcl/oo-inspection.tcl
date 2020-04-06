#!/usr/bin/env tclsh
#
# demonstrates object introspection

proc PrintObjectState {} {

  uplevel {
    puts stderr [format {%20s %s} self [self]]
    foreach i [list call caller method object class namespace next filter target] {
      set script [list self $i]
      catch {self $i} self_$i
      puts stderr [format {%20s %s} [list self $i:] [set self_$i]]
    }
    puts stderr ""
  }
  return
}

oo::class create SomeClass {
  constructor {} {
    puts stderr "Created instance [self] of <[self class]>."
  }
  method printIntrospectionInfo {} {

    puts stderr "\n...entering [self object]<[self class]> method [self method]\n"

    PrintObjectState
     
    puts stderr "\n...leaving [self object]<[self class]> method [self method]\n"
  }
}

oo::class create AnotherClass {
  constructor {} {
    puts "Created instance [self] of <[self class]>."
  }

  method testMethod {} {

    puts "\n...entering [self object]<[self class]> method [self method]\n"

    PrintObjectState

    SomeClass create someObject
    my TestForwarder

    puts "\n...leaving [self object]<[self class]> method [self method]\n"
  }
  forward TestForwarder someObject printIntrospectionInfo
}

AnotherClass create anotherObject
anotherObject testMethod

# SKIP THE FOLLOWING!!!!!!!!!!!!!!!!!!!!
return

# formal object/class tracing mechanism
rename trace ::tcl::trace
oo::class create trace {

  method DivertIfTraditionalTrace {$type} {
      switch -exact -- $type {
        class -
        object {
          tailcall 
        }
        default {
          tailcall trace $
        }
      }
    }
  }

  method add {type name opList command} {

  method remove {type name opList command}
  method info {type name opList command}

  forward variable my add variable
  forward vdelete my remove variable
  forward vinfo my info variable

  method PrintMethod args {
    puts "Hi there: $args"
  }
  method __ObjectMethodExecution { args} {
    ### MAGIC to stop trace from appearing in output
    if {[lindex [self target] 0] eq [self class]} {
      return [next {*}$args]
    }

    # puts "Tracing for: [self target]"
    set traceScript [namespace code {my __ObjectMethodExecution}]
    trace add execution next [list enter leave] $traceScript

    try {
      next {*}$args
    } finally {
      trace remove execution next [list enter leave] $traceScript
    }
  }

  filter __ObjectMethodExecution
}

