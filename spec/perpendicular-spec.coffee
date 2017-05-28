describe "The `perpendicular`-Function", ->
  perpendicular = require('../src/perpendicular')
  {vSP,vAdd,vSubst} = require('../src/common')
  ccw = require('../src/ccw')

  it "takes two points and a distance and creates a point", ->
    [x,y] = perpendicular([0,0],[2,-1],2)
    expect(x).to.be.a('number')
    expect(y).to.be.a('number')

  describe "the returned point", ->
    s = [s1,s2] = [0, 0]
    e = [x1,x2] = [2,-1]
    d = 2
    p = perpendicular(s,e,d)
    a = vSubst(s)(e)
    x = vSubst(s)(p)
    
    it "lies on a perpendicular going through the first point", ->
      expect(vSP(x)(a)).to.eql(0)

    it "has the expected distance", ->
      expect(vSP(x)(x)).to.almost.eql(d*d,10)

    it "lies left of s—e, when d is positive", ->
      expect(ccw(s,e,p)).to.be.above(0)

    it "lies right of s—e, when d is negative", ->
      d = -2
      p = perpendicular(s,e,d)
      expect(ccw(s,e,p)).to.be.below(0)
