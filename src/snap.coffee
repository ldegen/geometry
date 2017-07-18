kdbush = require "kdbush"

min = (arr)->arr.reduce (a,b)->Math.min(a,b)

module.exports = ({vertices,edges, radius=0.0001}) ->
  index = kdbush vertices
  lookup = (k)->
    [x,y]=vertices[k]
    indices = index.within x,y,radius
    j= min indices
    j

  newEdges = (edge.map(lookup) for edge in edges)
  maxIndex = newEdges
    .map ([a,b])->Math.max(a,b)
    .reduce (a,b)->Math.max(a,b)
  vertices: vertices.slice 0, maxIndex + 1
  edges:newEdges
    
