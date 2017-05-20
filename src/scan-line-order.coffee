ccw = require "../src/ccw"
{EPS, vSubst, vScale,vSP, vAlmostZero, almostZero} = require "../src/common"
order = (i,[p,q]) -> if p[i] > q[i] then [q,p] else [p,q]


# TODO: this module is a mess of trial and error
#       it realy needs some cleanup.

cmp = (axis)->(a,b)->
  c = _cmp (order axis, a), (order axis, b), true
  return (1 - 2*axis) * c if c?
_cmp = (a,b,tryInverse=false)->
  [a1,a2]=a
  [b1,b2]=b
  c1 = ccw a1,a2,b1
  c2 = ccw a1,a2,b2

  console.log "c1",c1,"c2",c2
  return c1 if  c1 * c2 > 0

  substA1 = vSubst(a1)
  substA2 = vSubst(a2)
  almostA1 =(v)->vAlmostZero substA1 v
  almostA2 =(v)->vAlmostZero substA2 v

  if almostA1 b1
    console.log "b1 almost a1", b1, a1
    return ccw a1,a2,b2 #a2[axis]-b2[axis]
  if almostA1 b2
    console.log "b2 almost a1", b2, a1
    return 0
  if almostA2 b1
    console.log "b1 almost a2", b1, a2
    return 0
  if almostA2 b2
    console.log "b2 almost a2", b2, a2
    return ccw a1,a2,b1

  if tryInverse
    console.log "try inverse"
    inv = _cmp b,a
    if inv? then -inv
  else # first try returned 0


module.exports.cmpH = cmp 1
module.exports.cmpV = cmp 0
