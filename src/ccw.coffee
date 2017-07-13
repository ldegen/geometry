# this implementation is a lot like the one given in Chapter 24 of Robert
# Sedgewick, Algorithms - Second Edition, Addison-Wesley, 1991
#
# We derivate some details:
#
# - Sedgewick's procedure returns 1,-1 or 0 to encode counter-clockwise,
# clockwise and "undefined". Our implementation returns a positive number for
# counter-clockwise motion a negative number for clockwise motion zero for
# "undefined" We handle the colinear cases the same as Sedgewick does.
#
# - Sedgewick's implementation assumes the positive y-axis is pointing up.  But
# when working with a computer screen, y-axis is pointing down most of the time
# for historical reasons. To avoid confusion we flip the sign.
#
# - We use this check a lot to determine on which side of some (infinit) line a 
#   point lies. In these cases, we assume the line is through p0 and p1.
#   We want to skip the special treatment of colinear cases here and just return
#   zero if p2 is on the line. This behaviour can be enabled by
#   passing a truthy value as fourth parameter.
#
#
#
EPS = 1e-12

module.exports = ([x0,y0],[x1,y1],[x2,y2],inf=false)->
  dx1= x1-x0; dy1=y1-y0
  dx2= x2-x0; dy2=y2-y0
  dsq1 = dx1*dx1+dy1*dy1
  dsq2 = dx2*dx2+dy2*dy2
  # Sedgewicks implementation assumes that the positive y axis is pointing up.
  # This is usually not the case on a computer screen, so we flip the sign.
  ccw=dy1*dx2-dx1*dy2

  

  if ccw*ccw < EPS
    # d1 and d2 are colinear, i.e. all three points
    # are on a line.

    # We handle these border cases just as Sedgewick does, but we flip
    # the sign.
    switch
      when inf then 0
      # p2 --- p0 --- p1
      when dx1*dx2 < 0 or dy1 * dy2 < 0 then 1

      # p0 --- p2 --- p1
      when dsq1 >= dsq2 then 0

      # p0 --- p1 --- p2
      else -1
  else ccw
