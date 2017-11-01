
gpsi = require('geojson-polygon-self-intersections')
EPSILON = 0.000001
isBoundaryCase = (frac)->
  e2 = EPSILON * EPSILON
  e2 >= (frac-1)*(frac-1) or e2 >= frac*frac
performInserts = (ring0, inserts=[])->
  ring = []
  readPos = 0
  cmp =(a,b)->
    d = a.pos - b.pos
    return d if d isnt 0
    a.frac - b.frac

  sortedInserts = inserts.sort cmp
  prev = null
  for {pos,v,frac},i in sortedInserts
    unless prev? and pos is prev.pos and Math.abs(frac-prev.frac)<EPSILON
      prev = {pos,v,frac}
      ring.push ring0[readPos...pos]..., v
      readPos = pos
  ring.push ring0[readPos...]...
  ring
    
module.exports = (rings)->
    inserts=[]
    addInsert = (ring,pos,frac,v)->
      if isBoundaryCase frac
        #console.log "not inserting",v, ring, frac
      else
        ringInserts = inserts[ring]?=[]
        ringInserts.push 
          pos: pos+1
          v:v
          frac:frac

    processIntersection = (isect, ring0, edge0, start0, end0, frac0, ring1, edge1, start1, end1, frac1, unique)->
      #console.log "isect", isect, "unique", unique, "ring0", ring0, "ring1",ring1
      #console.log "ring0",ring0,"edge0",edge0, "frac0", frac0
      #console.log "ring1",ring1,"edge1",edge1, "frac1", frac1
      addInsert ring0, edge0, frac0, isect
      addInsert ring1, edge1, frac1, isect
    feature =
      type: feature
      geometry:
        type: "Polygon"
        coordinates: rings
    gpsi feature, processIntersection, useSpatialIndex:true, reportVertexOnEdge:true, epsilon: EPSILON

    #console.log "inserts", inserts
    rings.map (ring,i)->
      performInserts(ring, inserts[i])
    
    
