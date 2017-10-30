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
    expect(output).to.almost.eql [
      [[0,0],[-1,0],[-2,0],[-2,-2],[0,-2],[0,-1],[0,0]]
      [[-1,-1],[0,-1],[1,-1],[1,1],[1,2],[2,2],[2,1],[1,1],[-1,1],[-1,0],[-1,-1]]
    ]

  describe "regression", ->
    it "does handle multiple intersections per edge segment", ->
      #the problem here is/was that there are more than one intersection per
      #original edge segment. This would violate my wrong(!) assumption that
      #there would be no more than one intersection per edge pair.
      
      input = [
        [[-1,-2],[2,1],[1,2],[-2,-1],[-1,-2]]
        [[1,-2],[2,-1],[-1,2],[-2,1],[1,-2]]
      ]

      output = insertIntersections input
      expect(output).to.almost.eql [
        [[-1,-2],[0,-1],[1,0],[2,1],[1,2],[0,1],[-1,0],[-2,-1],[-1,-2]]
        [[1,-2],[2,-1],[1,0],[0,1],[-1,2],[-2,1],[-1,0],[0,-1],[1,-2]]
      ]

    it "can do the fly", ->
      # the problem here was that intersections were reported as "not unique"
      # and were therefor skipped.
      # This was incorrect in situations where the same intersection appears several times.
      input =[
        [[0,-2],[2,-2],[2,2],[0,2],[0,-2]]
        [[-1,-1],[1,1],[1,-1],[-1,1],[-1,-1]]
      ]
      output = insertIntersections input
      expect(output).to.almost.eql [
         [[0,-2],[2,-2],[2,2],[0,2],[0,0],[0,-2]]
         [[-1,-1],[0,0],[1,1],[1,-1],[0,0],[-1,1],[-1,-1]]
      ]
