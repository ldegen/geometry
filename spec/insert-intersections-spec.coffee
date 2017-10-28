describe "Inserting intersection vertices", ->
  insertIntersections = require "../src/insert-intersections"
  it "works as expected",->
    input=[
      [[-2,-2],[0,-2],[0,0],[-2,0],[-2,-2]]
      [[-1,-1],[1,-1],[1,2],[2,2],[2,1],[-1,1],[-1,-1]]
    ]
    output=insertIntersections input
    expect(output).to.almost.eql [
      [[-2,-2],[0,-2],[0,-1],[0,0],[-1,0],[-2,0],[-2,-2]]
      [[-1,-1],[0,-1],[1,-1],[1,1],[1,2],[2,2],[2,1],[1,1],[-1,1],[-1,0],[-1,-1]]
    ]
  it "can insert between the last and the first vertex",->
    input=[
      [[0,0],[-2,0],[-2,-2],[0,-2],[0,0]]
      [[-1,-1],[1,-1],[1,2],[2,2],[2,1],[-1,1],[-1,-1]]
    ]
    output=insertIntersections input
    console.log "output", output
    expect(output).to.almost.eql [
      [[0,0],[-1,0],[-2,0],[-2,-2],[0,-2],[0,-1],[0,0]]
      [[-1,-1],[0,-1],[1,-1],[1,1],[1,2],[2,2],[2,1],[1,1],[-1,1],[-1,0],[-1,-1]]
    ]

