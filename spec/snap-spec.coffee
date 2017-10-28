describe "The `snap`-Function", ->

  snap = require "../src/snap"
  # this is the house of st claus, but the vertices of the inner x are sligthly off.
  vertices0 = [
    [0,0]
    [0,-1]
    [0.5,-2]
    [1,-1]
    [1,0]
    [0.01,-0.95]
    [1.02, -1.02]
    [-0.03, 0.01]
    [1,0]
  ]

  edges0 = [
    [0,1]
    [1,2]
    [2,3]
    [3,4]
    [4,0]
    [5,8]
    [7,6]
    [0,6] # make this a bit more fun by introducing a duplicate
  ]

  strips0 = [
    [0,1,2,3,4,0]
    [5,8]
    [7,6]
  ]


  it "modifies a mesh, collapsing vertices that are close to each other", ->

    {vertices, edges} = snap vertices:vertices0, edges:edges0, radius: 0.1

    expect(vertices).to.almost.eql vertices0.slice(0,5)
    expect(edges).to.eql [
      [0,1]
      [1,2]
      [2,3]
      [3,4]
      [4,0]
      [1,4]
      [0,3]
      [0,3]
    ]

  it "removes duplicate edges when asked to", ->
    {edges} = snap vertices:vertices0, edges:edges0, radius: 0.1, removeDuplicateEdges: true
    expect(edges).to.eql [
      [0,1]
      [1,2]
      [2,3]
      [3,4]
      [4,0]
      [1,4]
      [0,3]
    ]

  it "also works with edge strips as input", ->
    {edges,vertices} = snap vertices:vertices0, edges:strips0, radius:0.1
    expect(edges).to.eql [
      [0,1,2,3,4,0]
      [1,4]
      [0,3]
    ]

  it "cannot remove duplicate edges from edge strips", ->
    mistake = -> snap vertices:vertices0, edges:strips0, removeDuplicateEdges:true
    expect(mistake).to.throw()

  it "optionally accepts coordinate pairs instead of vertex ids", ->
    strips = strips0.map (strip)->strip.map (vid)->vertices0[vid]
    {edges,vertices} = snap edges:strips, radius:0.1
    expect(edges).to.eql [
      [0,1,2,3,4,0]
      [1,4]
      [0,3]
    ]
    expect(vertices).to.almost.eql vertices0.slice(0,5)

  describe "regressions", ->
    it "removes unused vertexes", ->
      strips =[
        [
          [ 0, -2 ]
          [ 2, -2 ]
          [ 2, 2 ]
          [ 0, 2 ]
          [ 0, 0 ]
          [ 0, -2 ]
        ]
        [
          [ -1, -1 ]
          [ 0, -0 ]
          [ 1, 1 ]
          [ 1, -1 ]
          [ 0, -0 ]
          [ -1, 1 ]
          [ -1, -1 ]
        ]
      ]

      {edges,vertices} = snap edges:strips, radius:0.1
      expect(vertices).to.eql [
        [ 0, -2 ]
        [ 2, -2 ]
        [ 2, 2 ]
        [ 0, 2 ]
        [ 0, 0 ]
        [ -1, -1 ]
        [ 1, 1 ]
        [ 1, -1 ]
        [ -1, 1 ]
      ]
      expect(edges).to.eql [
        [0,1,2,3,4,0]
        [5,4,6,7,4,8,5]
      ]
