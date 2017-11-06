skeleton = ([parent, children...],vertices,startWidth,endWidth)->
  for child in children
    [ vertices[parent]
      vertices[child[0]]
      if typeof startWidth is "function" then startWidth parent, child[0] else startWidth
      if typeof endWidth is "function" then endWidth parent, child[0] else endWidth
      skeleton(child, vertices, startWidth, endWidth)
    ]

module.exports = skeleton
