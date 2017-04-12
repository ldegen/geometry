describe "The `ccw` function", ->

  ccw = require "../src/ccw"

  describe "assumes moving from point A via B to C", ->
    it "returns a positive value for counter-clockwise motion", ->
      expect(ccw [0,0], [1,-1], [-1,-1]).to.be.above 0
    it "returns a negative value for clockwise motion", ->
      expect(ccw [0,0], [-1,-1],[1, -1]).to.be.below 0
  describe "when all three points are on a line", ->
    it "returns +1 when starting point is between the last two points", ->
      expect(ccw [0,0],[1,1],[-1,-1]).to.equal 1
    it "returns 0 when the end point is between the first two points", ->
      expect(ccw [-1,-1],[1,1],[0,0]).to.equal 0
    it "returns -1 when there is no change of direction", ->
      expect(ccw [-1,-1],[0,0],[1,1]).to.equal -1
