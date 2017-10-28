describe "Polygon Simplifier", ->
  simplify = require "../src/simplify"
  it "takes an array of complex polygons and decomposes them into simple, non-intersecting components", ->
    input = [
      [[0,-2],[2,-2],[2,2],[0,2],[0,-2]]
      [[-1,-1],[1,1],[1,-1],[-1,1],[-1,-1]]
    ]
    output = simplify input
    for ring, ringId in output
      console.log "ring", ringId, "parent", ring.parent, ring.coords()

    expect(output).to.almost.eql 
      type: "FeatureCollection"
      features: [
        type: "Feature"
        geometry:
          type: "Polygon"
          coordinates:[[[-1,-1],[0,0],[-1,1],[-1,-1]]]
      ,
        type: "Feature"
        geometry:
          type: "Polygon"
          coordinates:[
            [[0,0],[0,-2],[2,-2],[2,2],[0,2],[0,0]]
            [[0,0],[1,1],[1,-1],[0,0]]
          ]
      ]
