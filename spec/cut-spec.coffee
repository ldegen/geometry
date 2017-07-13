util = require "util"
util.inspect.defaultOptions.depth=5
describe "The `cut`-function", ->
  

  cut = require "../src/cut.litcoffee"
  
  letterS = [
    [0,  0]
    [3,  0]
    [3, -3]
    [1, -3]
    [1, -4]
    [3, -4]
    [3, -5]
    [0, -5]
    [0, -2]
    [2, -2]
    [2, -1]
    [0, -1]
  ]
  [a,b,c,d,e,f,g,h,i,j,k,l] = letterS

  cuttingEdge =[
    [1,  0]
    [2, -5]
  ]

  intersections = ([1+ii/5, -ii] for ii in [0 .. 5])
  [A,B,C,D,E,F] = intersections
  
  it "cuts an edge ring along an infinite straight line", ->
    r=cut(cuttingEdge) letterS
    expect(r).to.be.an.instanceof Array
    expect(r.length).to.eql 2
    [left,right] = r
    expect(left).to.almost.eql [
      [l,a,A,B]
      [D,d,e,E,F,h,i,C]
    ]
    expect(right).to.almost.eql [
      [A,b,c,D,C,j,k,B]
      [E,f,g,F]
    ]
  it "handles cases where there are no intersections", ->
    r = cut([[-1,0],[-1,-1]]) letterS
    [rest..., last] = letterS
    expect(r).to.eql [
      []
      [[last, rest...]]
    ]

  it "gracefully handles edges that are contained in the cutting edge", ->
    r = cut([[0,0],[0,-1]]) letterS
    [rest..., last] = letterS
    expect(r).to.eql [
      []
      [[last, rest...]]
    ]
    intersections = ([1, -ii] for ii in [0 .. 5])
    [A,B,C,D,E,F] = intersections
    [left,right] = cut([[1,0],[1,-1]]) letterS
    expect(left).to.almost.eql [
      [l,a,A,B]
      [D,E,F,h,i,C]
    ]
    expect(right).to.almost.eql [
      [A,b,c,D,C,j,k,B]
      [E,f,g,F]
    ]
