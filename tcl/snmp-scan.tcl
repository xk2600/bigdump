proc dottedDecimal {longIp} {
  
  set octet {{longIp index} { return [expr {($longIp & (255 << ($index * 8))) >> ($index * 8)}] }}
  return "[apply $octet $longIp 3].[apply $octet $longIp 2].[apply $octet $longIp 1].[apply $octet $longIp 0]"
}

proc ip {cidr} {
  lassign [split $cidr {/}] ip masklen
  lassign [split $ip {.}] ip3 ip2 ip1 ip0
  set ip [expr {(${ip3} * 2**24) + (${ip2} * 2**16) + (${ip1} * 2**8) + ${ip0}}]
  lappend ip [expr {${ip} + 2**(32-${masklen})}]
  return $ip
}

proc scan {start end} {
  for {set iter $start} {$iter < $end} {incr iter} {
    puts -nonewline stderr "${iter}::[dottedDecimal $iter]..."
    if {[catch {exec ping -f -c 1 -w 2 -i 1 $iter} err]} {
      puts "timed out."       
    } else {
      puts -nonewline "is ALIVE, POLLING:"
      set snmpresp [catch {exec snmpget -v 2c -t 1 -r 1 -L n -c ORION [dottedDecimal $iter] sysName.0} r]
      puts $snmpresp-$r
    }
  }
}


# usage: ip cidr
#
#   cidr     dottedDecimal/maskLen
#
# example:
#
#   % cidr 10.215.32.0/20
#   181870592 
#

# usage: scan begin end
#
#   begin    long integer version of starting ip.
#   end      long integer version of ending ip.
# 
# scan {*}[ip 10.215.32.0/20]
