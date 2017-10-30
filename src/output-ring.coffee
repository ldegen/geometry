
pip = require "point-in-polygon"

{ringArea} = require "./common"
Ring = require "./ring"

module.exports = (arcs, rings, coordinates, isJoint)->
  vIds = []
  coords = null
  area = null
  peersAtJoints = null
  jointPositions = {}
  for arc in arcs
    {ringIndex, positionInRing} = arc
    ring = rings[ringIndex].set(positionInRing)
    jointPositions[ring()] = vIds.length
    first = true
    while first or not isJoint(ring())
      first = false
      vIds.push ring()
      ring = ring.rotate(1)
  self = Ring vIds
  self.coords = ->
    if coords is null
      coords = vIds.map coordinates
    coords
  self.area= ->
    if area is null
      area = ringArea @coords()
    area
  self.contains= (p)->pip p, @coords()
 
  self.jointPositions = jointPositions
  # report a map with vId of joints as keys and
  # an adjacent vertex as value. The other vertex will be either
  # the next vertice (if the ring is oriented clockwise)
  # or to the previous (if the ring is ccw)
  # We need this information for containment tests.
  self.peersAtJoints= ->
    if peersAtJoints is null 
      peersAtJoints = {}
      for vId,pos of jointPositions
        peer = if @area() > 0 then pos - 1 else pos + 1
        peersAtJoints[vId]=self(peer)
    peersAtJoints
     
  self


