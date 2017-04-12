ccw = require "./ccw"

intersect = (p1,p2,p3,p4)->
  ( ccw(p1,p2,p3) * ccw(p1,p2,p4) <= 0 ) and (
    ccw(p3,p4,p1) * ccw(p3,p4,p2) <=0 )

module.exports = intersect
