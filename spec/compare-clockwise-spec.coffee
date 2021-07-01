describe "Sorting adjacent edges clockwise", ->

  compare = require('../src/compare-bones-clockwise')

  {floor, random, sin, cos} = Math

  # Fisher-Yates seems to be The Way to do it.
  # Ask the googles.
  shuffel = (array0)->
    array = array0.slice()
    for remaining in [array.length .. 1]
      i = remaining - 1
      j = floor(random()*remaining)
      tmp = array[j]
      array[j] = array[i]
      array[i] = tmp
    array

  clock = (t)->
    a = t * Math.PI / 6
    [sin(a), -cos(a), "clock_"+t]

  z = [0,0]
  parent = [clock(6), z]
  child = (t)->[z,clock(t)]
  children = [1,2,3,4,5,7,8,9,10,11,12].map child
  children = shuffel(children)

  it "can be used to sort children clockwise relative to the parent", ->
    children.sort(compare(parent))

    expect(children).to.eql([7,8,9,10,11,12,1,2,3,4,5].map(child))

