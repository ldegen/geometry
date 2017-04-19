describe "The scan-line-order relation", ->

  {cmpH, cmpV} = require "../src/scan-line-order"

  describe "for a horizontal scan line", ->

    it "returns a negative value if s1 is left of s2", ->
      expect(cmpH [[-2,0], [-1,-1]], [[1,-1], [2,0]]).to.be.below 0

    it "returns a negative value if s2 is right of s1", ->
      expect(cmpH [[-2,0], [0,-2]], [[0,0], [1,1]] ).to.be.below 0

    it "returns a positive value if s1 is right of s2", ->
      expect(cmpH  [[1,-1], [2,0]], [[-2,0], [-1,-1]]).to.be.above 0

    it "returns a positive value if s2 is left of s1", ->
      expect(cmpH [[0,0], [1,1]], [[-2,0], [0,-2]]).to.be.above 0


    describe "if both segments share a vertex", ->
      it "compares the x-position of the other vertices,
          if they are both above or below the common vertex", ->
        expect(cmpH [[-2,0], [0,2]], [[0,2], [2,0]]).to.be.below 0
        expect(cmpH [[2,0],[0,-2]], [[0,-2], [-2,0]]).to.be.above 0
      it "returns zero, of the common vertex is between the other two", ->
        expect(cmpH [[1,1],[2,0]],[[0,-2], [2,0]]).to.equal 0
        expect(cmpH [[-1,-1],[-2,0]],[[-2,0], [0,2]]).to.equal 0

    describe "if both segments share more than one point", ->
      it "returns zero", ->
        expect(cmpH [[-1,1],[1,-1]],[[1,-1], [0,0]]).to.equal 0
        expect(cmpH [[0,-2],[-2,0]],[[-1,-1], [-2,0]]).to.equal 0

