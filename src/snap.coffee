kdbush = require "kdbush"

min = (arr)->arr.reduce (a,b)->Math.min(a,b)
dedupe = (edges)->
  lookup = {}
  edges.filter (edge)->
    if not lookup[edge]?
      lookup[edge]=true
      true
    else
      false

module.exports = ({vertices,edges, radius=0.0001, removeDuplicateEdges=false}) ->
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
  edges:if removeDuplicateEdges then dedupe newEdges else newEdges
    
