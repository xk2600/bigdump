# TCL

*Copyright (c) 2018, Christopher M. Stephan, All rights reserved. see LICENSE for further details.*

## Purpose

This directory contains little scripts which I have used at various times to either ask questions about on #tcl in irc, or to showcase examples for others of interesting things I have either attempted or am thinking about. Feel free to peruse to your hearts desire.

## Contents

### QuarterCircle.tcl

This file contains two examples of how to create a quarter circle in bitmapped format using two while loops.

 - roundedCorner {r x y}, where r is radius, x is x-offset, and y is y-offset.
 - bitbangArc {r}, simply finds the distance in pixels from the y-axis (x) for each iteration of y-pixels. Since we know the arc always decreases in size from the initial point, we use this to "trace" the arc. Instead of resetting the x value on the next line, we just stay where we are and test to see if the summed squares of x and y are less than the square of r. At the point it is not, we decrease x by 1 pixel until it is and move to the next line.


