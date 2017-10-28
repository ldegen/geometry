
gpsi = require('geojson-polygon-self-intersections')

performInserts = (ring0, inserts)->
  ring = []
  readPos = 0
  sortedInserts = ({pos,v} for pos,v of inserts).sort ({pos:a},{pos:b})->a-b
  for {pos,v} in sortedInserts
    ring.push ring0[readPos...pos]..., v
    readPos = pos
  ring.push ring0[readPos...]...
  ring
    
module.exports = (rings)->
    inserts=[]
    addInsert = (ring,pos,v)->
      ringInserts = inserts[ring]?={}
      ringInserts[pos+1]=v

    processIntersection = (isect, ring0, edge0, start0, end0, frac0, ring1, edge1, start1, end1, frac1, unique)->
      addInsert ring0, edge0, isect
      addInsert ring1, edge1, isect
    feature =
      type: feature
      geometry:
        type: "Polygon"
        coordinates: rings
    gpsi feature, processIntersection, true

    rings.map (ring,i)->
      performInserts(ring, inserts[i])
    
    
