
describe "The skin-Function", ->
  skin = require "../src/skin"
  trapezoid = require "../src/trapezoid"
  z = [0,0]
  A = [0,-1]
  B = [-1,-2]
  C = [-2,-3]
  D = [-1,-3]
  E = [1,-1]
  F = [1,-2]
  sq2 = Math.sqrt(2)
  draw = (vertices)->
    s=vertices
      .map ([x,y])->"#{x} #{y}"
      .join (" L ")
    "<path class=\"skin\" d=\"M #{s} Z\" />"
  flatten = ([start,end,startWidth,endWidth,children=[]])->
    tail = children.map flatten
    [[start,end,startWidth,endWidth,[]]].concat tail...

  it "creates a triangular skin for a single bone", ->
    bone = [z,A,0.5,0.25]
    expect(skin(bone)).to.eql [
      [-0.50,  0]
      [ 0,    -2]
      [ 0.50,  0]
    ]


  it "creates a nice xmas tree for a linear chain of bones",->
    bone = [z,A,0.5,0.25,[
      [A,[0,-2], 0.5, 0.25, [
        [[0,-2],[0,-3], 0.5, 0.25]
      ]]
    ]]
    expect(skin(bone)).to.eql [
      [-0.50,  0]
      [-0.25, -1]
      [-0.50, -1]
      [-0.25, -2]
      [-0.50, -2]
      [    0, -4]
      [ 0.50, -2]
      [ 0.25, -2]
      [ 0.50, -1]
      [ 0.25, -1]
      [ 0.50,  0]
    ]

  it "also handles chains where the direction changes", ->
    bone = [[0,0], [0,-1],.5,.25,[
      [[0,-1], [1,-1], .5, .25, [
        [[1,-1],[1,-2], .5, .25, []]
      ]]
    ]]
    #expect(skin(bone)).to.eql [
    #  [-0.5,0]
    #  [-0.125,-1.625]
    #  [0.625,-1.375]
    #  [1,-3]
    #  [1.625,-0.875]
    #  [0.375,-0.625]
    #  [0.5, 0]
    #]
  xit "takes a skeleton and puts on a skin", ->
    # our skeleton looks something like this:
    #
    #   C D
    #    \|
    #     B   F
    #      \  |
    #       A-E
    #       |
    #       z
    #M 0 0 L 0 -1 L -1 -2 L -2 -3 M -1 -2 L -1 -3 M 0 -1 L 1 -1 L 1 -2
    # All diagonal bones start of with width sqrt(2)/2 and
    # end with sqrt(2)/4. The horizontal and vertical ones
    # use width 1/2 and 1/4. Disregarding the limitations of
    # BFP arithmetics, this should keep all trapezoid
    # vertices reasonably close to a [0.5,0.5] grid. Thus,
    # the resulting skin vertices should all have rational
    # coordinates.

    skeleton = [z, A, 0.5, 0.25,[
      [A, B, 0.5*sq2, 0.25*sq2 ,[
        [B, C, 0.5*sq2, 0.25*sq2, []]
        [B, D, 0.5, 0.25, []]
      ]]
      [A, E, 0.5, 0.25, [
        [E, F, 0.5, 0.25, []]
      ]]
    ]]

    vertices = skin(skeleton)
    # i have no good way of testing this yet.
    # lets try something different.
    console.log draw vertices

    for bone in flatten skeleton
      console.log draw trapezoid bone

    # not sure how to
