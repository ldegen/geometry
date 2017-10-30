describe "Edge Redundance detector", ->
  redundance = require "../src/redundance"
  vertices = undefined
  strips = undefined
  beforeEach ->
    strips = [
      [0,1,8,5,6,0]
      [4,5,8,7,4]
      [3,2,1,8,5,4,3]
    ]

  it "finds edges that are used more than once", ->
    edgeRedundance = redundance strips

    expect(edgeRedundance).to.eql
      '1,8': ascending:[0,2], descending:[]
      '5,8': ascending:[1], descending:[0,2]
      '4,5': ascending:[1], descending:[2]

