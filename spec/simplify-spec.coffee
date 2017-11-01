describe "Polygon Simplifier", ->
  simplify = require "../src/simplify"
  it "takes an array of complex polygons and decomposes them into simple, non-intersecting components", ->
    input = [
      [[0,-2],[2,-2],[2,2],[0,2],[0,-2]]
      [[-1,-1],[1,1],[1,-1],[-1,1],[-1,-1]]
    ]
    output = simplify input
    expect(output).to.eql 
      type: "FeatureCollection"
      features: [
        type: "Feature"
        geometry:
          type: "Polygon"
          coordinates:[
            [[0,-2],[2,-2],[2,2],[0,2],[0,0],[0,-2]]
            [[0,0],[1,1],[1,-1],[0,0]]
          ]
      ,
        type: "Feature"
        geometry:
          type: "Polygon"
          coordinates:[[[0,0],[-1,1],[-1,-1],[0,0]]]
      ]

  it "can be configured to remove rings that are too small", ->
    # magnitude of areas should be 1, 4, 16 
    input = [
      [[-0.5,-0.5], [0.5,-0.5], [0.5,0.5],[-0.5, 0.5],[-0.5,-0.5]]
      [[-1,-1], [1,-1],[1,1],[-1,1],[-1,-1]]
      [[-2,-2], [2,-2],[2,2],[-2,2],[-2,-2]]
    ]
    {ringArea} = require "../src/common"

    output = simplify input, minArea: 4

    expect(output).to.eql
      type: "FeatureCollection"
      features:[
        type: "Feature"
        geometry:
          type:"Polygon"
          coordinates:[
            [[-2,-2], [2,-2],[2,2],[-2,2],[-2,-2]]
            [[-1,-1], [1,-1],[1,1],[-1,1],[-1,-1]]
          ]
      ]

  it "can be configured to remove rings that have the same orientation as their parent", ->
    # assuming your application uses ring orientation correctly, this will allow
    # some applications (read: our application :-) ) to eliminate redundant details from your
    # geometry. Think of to bars forming an X-like crossing shape. If both
    # bars have the same orientation, the result will trace the outline and produce
    # a second ring that traces a little box in the middle of the crossing.
    # This box has the same orientation as the parent and is in fact redundant.

    input = [
      [[-1,-2],[2,1],[1,2],[-2,-1],[-1,-2]]
      [[1,-2],[2,-1],[-1,2],[-2,1],[1,-2]]
    ]

    output = simplify input, removeRedundantRings: true

    expect(output.features[0].geometry.coordinates).to.almost.eql [
            [[-1,-2],[0,-1],[1,-2],[2,-1],[1,0],[2,1],[1,2],[0,1],[-1,2],[-2,1],[-1,0],[-2,-1],[-1,-2]]
    ]
    expect(output).to.eql 
      type: "FeatureCollection"
      features:[
        type: "Feature"
        geometry:
          type:"Polygon"
          coordinates:[
            [[-1,-2],[-0,-1],[1,-2],[2,-1],[1,0],[2,1],[1,2],[-0,1],[-1,2],[-2,1],[-1,0],[-2,-1],[-1,-2]]
          ]
      ]
  
  it "can be configured to ignore redundant edges", ->
    input = [
      [[0,0],[1,0],[1,2],[0,2],[0,0]]
      [[1,1],[2,1],[2,2],[1,2],[1,1]]
      [[1,0],[1,2],[3,2],[3,0],[1,0]]
    ]

    output = simplify input, ignoreRedundantEdges: true

    expect(output).to.eql
      type: "FeatureCollection"
      features:[
        type: "Feature"
        geometry:
          type: "Polygon"
          coordinates:[
            [[0,0],[0,2],[1,2],[1,1],[2,1],[2,2],[3,2],[3,0],[1,0],[0,0]]
          ]
      ]
