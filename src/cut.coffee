module.exports = ([s1,s2])->(ring)->

  {coefficients, vInterpolate} = require './common'
  ccw = require './ccw'
  # Note: we assume that the cutting edge is
  # the infinite extension of the segment s1 -> s2
  # So we create a special intersect test first:

  intersects = (a,b)-> ccw(s1,s2,a) * ccw(s1,s2,b) < 0

  # for each intersection, we need to know the coefficient along the cutting edge
  # so we can later sort and pair up the intersection points.

  lambda = (a,b)->
    coefficients([s1,s2],[a,b])?[0]
  interpolate = vInterpolate(s1,s2)
  
  # Next, iterate the edges. As the first edge, connect the last and the first vertex
  edges = ring.map (v,i,vs)->
    if i is 0 then [vs[vs.length-1],v] else [vs[i-1],v]

  # find all intersections and remember their position in the edge list.
  # This position is corresponds to that of the target vertex within the original ring.
  intersections = ( [i, lambda(a,b)] for [a,b],i in edges when intersects(a,b) )

  
  # sort intersections along the cutting edge
  intersections.sort ([i,λ],[j,μ])-> λ - μ


  # we take a look at the minimum intersection to determine winding
  # direction of the ring. We need to know this, so we can later determine
  # which parts are left and which are right of the cutting edge.
  #
  [k]=intersections[0]

  # if s1-s2-k is a clockwise motion then k is right of s1-s2, which in turn means
  # the ring orientation is counter clockwise.
  ringIsCounterClockWise = ccw(s1,s2,ring[k]) < 0

  leftPairs = {}
  rightPairs = {}

  # pair up the intersections
  for i in [0 ... intersections.length/2 ]
    if ringIsCounterClockWise
      a = intersections[2*i]
      b = intersections[2*i + 1]
    else
      b = intersections[2*i]
      a = intersections[2*i + 1]

    leftPairs[a[0]] = [a,b]
    rightPairs[b[0]] = [b,a]

  # Each ring has to contain at least one pair.
  #
  # So we always start a new ring with a pair of intersections.
  # We then keep walking through the vertices of the original ring.
  # But when we come across an intersection, we lookup the corresponding
  # pair and use it as a loop hole and remove it from the lookup.
  # We stop once we arrive again at our starting point.
  makeRing = (lookup) -> ([i,λ],[j,μ])->
    k = j
    r = [interpolate(λ), interpolate(μ)]
    while k isnt i
      pair = lookup[k]
      if pair?
        r.push interpolate(pair[0][1]), interpolate(pair[1][1])
        delete lookup[k]
        k=pair[1][0]
      else
        r.push ring[k]
        k = (k + 1) % ring.length
    r


  # Now, all that's left to do, is actually creating those rings for both left and right side.
  
  leftRings = (makeRing(leftPairs) a,b for _, [a,b] of leftPairs)
  rightRings = (makeRing(rightPairs) a,b for _, [a,b] of rightPairs)


  [leftRings,rightRings]
    





