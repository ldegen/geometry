describe "The skeleton-function", ->
  skeleton = require "../src/skeleton"
  it "takes a tree and a list of positions and creates a skeleton", ->
    z = [0,0]
    A = [0,-1]
    B = [-1,-2]
    C = [-2,-3]
    D = [-1,-3]
    E = [1,-1]
    F = [1,-2]

    vertices = [z,A,B,C,D,E,F]

    tree = [0,
      [1,
        [2,
          [3]
          [4]
        ]
        [5,
          [6]
        ]
      ]
    ]
    
    startWidth = 0.5
    endWidth = 0.25
    bones = skeleton(tree,vertices,startWidth,endWidth)
    expect(bones).to.eql [
      [z, A, 0.5, 0.25,[
        [A, B, startWidth, endWidth ,[
          [B, C, startWidth, endWidth, []]
          [B, D, startWidth, endWidth, []]
        ]]
        [A, E, startWidth, endWidth, [
          [E, F, startWidth, endWidth, []]
        ]]
      ]]
    ]
