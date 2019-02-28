proc roundedCorner {r x y} {

  #    x xmax   r
  #    0   16  16
  #  -16    0  16

  set xmin $x
  set ymin $y

  set xmax [expr {$x + $r}]
  set ymax [expr {$y + $r}]

  set rmax [expr {pow($r,2)}]

  set h [expr {$r/4}]

  puts "\n\nr:$r->$rmax x:$x->$xmax y:$y->$ymax h:$h"

  set result {}
  set binres {}

  while {$y <= $ymax} {
    set x $xmin
    set line {}
    while {$x <= $xmax} {

      set xySqrSum [expr { pow($x,2)+pow($y,2) }]
      append line [expr {($xySqrSum <= $rmax) ? 1 : 0}]
      incr x
    }
    append binres "$line\n"
    incr y
  }
  puts \n\n$binres\n\n$result
}

proc bitbangArc {r} {

  set rSqr [expr {pow($r,2)}]
  set y 0
  set x $r
  
  set linelen {}
  
  puts "\n\nr:$r rSqr:$rSqr x:$x y:$y"
  
  while {$y < $r} {
    while { (pow($x,2)+pow($y,2)) >= $rSqr } {
      puts "($x,$y):  x\u00B2+x\u00B2:[expr {(pow($x,2) + pow($y,2))}]    <=   r\u00B2:$rSqr"
      incr x -1
    } 
    lappend linelen $x;
    incr y
  } 
  
  puts "\n\n \n\n"
  foreach bits $linelen {
  }
  
  return $linelen
} 

proc drawMask {r {invX 0} {invY 0}} {
  
  set lBitLen [list]

  if {invX} {
    set lBitLen lreverse [bitBangArc $r]]
  } else {
    set lBitLen [bitBangArc $r]
  }

  set byteLen [expr

  if {invY} {
    foreach row
  } else {
    foreach row $lBitLen {
      
    }
  }
}
