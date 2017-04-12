describe "The intersect-function", ->

  # A note on complexity:
  #
  # How many "kinds" of constellations are there?
  #
  # First, we can look at the lines that the two segments reside on.
  #
  # We ignore the parallel case, not because it cannot happen, but because
  # it is in fact not a special case in our implementation.
  #
  # So first, we look at the non-colinear (a.k.a. "normal") case.
  # There are 25 different equivalence classes of test cases to consider:
  #
  #  ╔══════════╦══════════╦═════════╦═════════╦══════════╗
  #  ║   ├———┤  ║  ├———┤   ║  ├———┤  ║  ├———┤  ║  ├———┤   ║
  #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
  #  ╠══════════╬══════════╬═════════╬═════════╬══════════╣
  #  ║ ┬ ├———┤  ║  ┌———┤   ║  ├—┬—┤  ║  ├———┐  ║  ├———┤ ┬ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
  #  ╠══════════╬══════════╬═════════╬═════════╬══════════╣
  #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ │  ┼———┼ ║  ├———┼   ║  ├—┼—┤  ║  ├———┤  ║  ┼———┼ │ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
  #  ╠══════════╬══════════╬═════════╬═════════╬══════════╣
  #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ ┴ ├———┤  ║  └———┤   ║  ├—┴—┤  ║  ├———┘  ║  ├———┤ ┴ ║
  #  ╠══════════╬══════════╬═════════╬═════════╬══════════╣
  #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
  #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
  #  ║   ├———┤  ║  ├———┤   ║  ├———┤  ║  ├———┤  ║  ├———┤   ║
  #  ╚══════════╩══════════╩═════════╩═════════╩══════════╝
  #
  #
  # Then there are seven colinear cases:
  #
  #  ╔════════╦═══════╦══════╦═════╦══════╦═══════╦════════╗
  #  ║ └─┘┌─┐ ║ └─┼─┐ ║ └┬┴┐ ║ ├—┤ ║ ┌┴┬┘ ║ ┌─┼─┘ ║ ┌─┐└─┘ ║
  #  ╚════════╩═══════╩══════╩═════╩══════╩═══════╩════════╝
  #
  # So... theoretically we would need *at least* 32 test cases. :-(


  intersect = require "../src/intersect"
  it "returns true if the two line segments intersect", ->
    #  ║   ├———┤  ║  ├———┤   ║  ├———┤  ║  ├———┤  ║  ├———┤   ║
    #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
    expect(intersect [-1,1], [0,2], [-1,-1], [0,-2]).to.be.false
    expect(intersect [-1,1], [0,2], [-2,0], [0,-2]).to.be.false
    expect(intersect [0,0], [1,1], [-2,0], [0,-2]).to.be.false
    expect(intersect [1,-1], [2,0], [-2,0], [0,-2]).to.be.false
    expect(intersect [1,-1], [2,0], [-2,0], [-1,-1]).to.be.false


    #  ║ ┬ ├———┤  ║  ┌———┤   ║  ├—┬—┤  ║  ├———┐  ║  ├———┤ ┬ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
    expect(intersect [-2,0], [0,2], [-1,-1], [0,-2]).to.be.false
    expect(intersect [-2,0], [0,2], [-2,0], [0,-2]).to.be.true
    expect(intersect [-1,-1], [1,1], [-2,0], [0,-2]).to.be.true
    expect(intersect [0,-2], [2,0], [-2,-0], [0,-2]).to.be.true
    expect(intersect [0,-2], [2,0], [-2,0], [-1,-1]).to.be.false



    #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ │  ┼———┼ ║  ├———┼   ║  ├—┼—┤  ║  ├———┤  ║  ┼———┼ │ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
    expect(intersect [-2,0], [0,2], [0,0], [1,-1]).to.be.false
    expect(intersect [-2,0], [0,2], [-1,1], [1,-1]).to.be.true
    expect(intersect [-1,-1], [1,1], [-1,1], [1,-1]).to.be.true
    expect(intersect [0,-2], [2,0], [-1,1], [1,-1]).to.be.true
    expect(intersect [0,-2], [2,0], [-1,1], [0,0]).to.be.false




    #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ ┴ ├———┤  ║  └———┤   ║  ├—┴—┤  ║  ├———┘  ║  ├———┤ ┴ ║
    expect(intersect [-2,0], [0,2], [1,1], [2,0]).to.be.false
    expect(intersect [-2,0], [0,2], [0,2], [2,0]).to.be.true
    expect(intersect [-1,-1], [1,1], [0,2], [2,0]).to.be.true
    expect(intersect [0,-2], [2,0], [0,2], [2,0]).to.be.true
    expect(intersect [0,-2], [2,0], [0,2], [1,1]).to.be.false




    #  ║ ┬        ║  ┬       ║    ┬    ║      ┬  ║        ┬ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ │        ║  │       ║    │    ║      │  ║        │ ║
    #  ║ ┴        ║  ┴       ║    ┴    ║      ┴  ║        ┴ ║
    #  ║   ├———┤  ║  ├———┤   ║  ├———┤  ║  ├———┤  ║  ├———┤   ║
    expect(intersect [-2,0], [-1,1], [1,1], [2,0]).to.be.false
    expect(intersect [-2,0], [-1,1], [0,2], [2,0]).to.be.false
    expect(intersect [-1,-1], [0,0], [0,2], [2,0]).to.be.false
    expect(intersect [0,-2], [1,-1], [0,2], [2,0]).to.be.false
    expect(intersect [0,-2], [1,-1], [0,2], [1,1]).to.be.false



    #  ╔════════╦═══════╦══════╦═════╦══════╦═══════╦════════╗
    #  ║ └─┘┌─┐ ║ └─┼─┐ ║ └┬┴┐ ║ ├—┤ ║ ┌┴┬┘ ║ ┌─┼─┘ ║ ┌─┐└─┘ ║
    #  ╚════════╩═══════╩══════╩═════╩══════╩═══════╩════════╝

    
    expect(intersect [-3,1], [-1,0], [1,-1], [3,2]).to.be.false
    expect(intersect [-1,0], [1,-1], [1,-1], [3,2]).to.be.true
    expect(intersect [-3,1], [1,-1], [-1,0], [3,2]).to.be.true
    expect(intersect [-1,0], [1,-1], [-1,0], [1,-1]).to.be.true
    expect(intersect [-1,0], [3,-2], [-3,1], [1,-1]).to.be.true
    expect(intersect [1,-1], [3,-2], [-1,0], [1,-1]).to.be.true
    expect(intersect [1,-1], [3,-2], [-3,1], [-1,0]).to.be.false

