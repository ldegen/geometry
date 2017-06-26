describe "The `cut`-function", ->
  

  cut = require "../src/cut"
  
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
      [A,B,l,a]
      [E,F,h,i,C,D,d,e]
    ]
    expect(right).to.almost.eql [
      [D,C,j,k,B,A,b,c]
      [F,E,f,g]
    ]
    
