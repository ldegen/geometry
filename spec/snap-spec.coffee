describe "The `snap`-Function", ->

  snap = require "../src/snap"

  it "modifies a mesh, collapsing vertices that are close to each other", ->
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
    ]
    
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

    ]
