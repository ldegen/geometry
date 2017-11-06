kdbush = require "kdbush"
min = (arr)->arr.reduce (a,b)->Math.min(a,b)
dedupe = (edges)->
  lookup = {}
  newEdges = []
  for edge, i in edges
    throw new Error "Not implemented yet: removing duplicate edges from edge strips" if edge.length isnt 2
    entry = lookup[edge]
    if entry?
      entry.push i
    else
      lookup[edge] = [i]
      newEdges.push edge

  edges: newEdges
  originalEdgeIds: newEdges.map (edge)->lookup[edge]

module.exports = ({vertices:vertices0,edges:edges0, radius=0.0001, removeDuplicateEdges=false}) ->
  if vertices0?
    vertices = vertices0
    edges = edges0
  else
    vertices = []
    edges = []
    for edge in edges0
      offset = vertices.length
      vertices.push edge...
      edges.push edge.map (_,i)->offset+i
      
  index = kdbush vertices
  lookup = ([x,y])->
    #[x,y]=vertices[k]
    indices = index.within x,y,radius
    j= min indices
    j

  # Create an array that only contains the first
  # appearance of any coordinate pair
  compactVertices = []

  # This will be used to map the old vIds into the
  # new compact vertex array.
  vIdMap = []

  for coords, origId in vertices
    minId = lookup coords
    if minId is origId
      # first appearance of this vertex, keep it.
      vIdMap[origId] =  compactVertices.length
      compactVertices.push vertices[origId]
    else if minId < origId
      # a vertex with (almost) the same coordinates
      # exists at an earier position, so we do not
      # copy the current one. 
      vIdMap[origId] = vIdMap[minId]
  
  # map the edges/edge strips over to use the compact vertex
  # array positions as vertex ids.

  compactEdges = (edge.map((origId)->vIdMap[origId]) for edge in edges)


  if removeDuplicateEdges
    {edges:newEdges, originalEdgeIds} = dedupe compactEdges

    vertices: compactVertices
    edges: newEdges
    originalEdgeIds: originalEdgeIds

  else

    vertices: compactVertices
    edges: compactEdges
    
