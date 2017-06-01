skeleton = ([parent, children...],vertices,startWidth,endWidth)->
  for child in children
    [ vertices[parent]
      vertices[child[0]]
      startWidth
      endWidth
      skeleton(child, vertices, startWidth, endWidth)
    ]

module.exports = skeleton
