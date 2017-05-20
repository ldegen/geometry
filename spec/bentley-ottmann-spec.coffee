describe "The Bentley-Ottmann algorithm",->

  intersections = require "../src/bentley-ottmann"

  # Note that according to wikipedia, the original algorithm
  # relies on a lot of assumptions.
  #
  #   A1: line segments are not vertical,
  #   A2: line segment endpoints do not lie on other line segments
  #   A3: crossings are formed by only two line segments
  #   A4: no two event points have the same x-coordinate.
  #
  # It is fairly obvious that those assumptions were choosen
  # to make the algorithm more easy to explain. There is no
  # technical necessity for any of the assumptions, so our
  # implementation shall *not* require them.

  it "finds pairwise intersections in a set of line segments", ->

    # This example violates A4.

    a=[[-4, -4], [ 1,  3]]
    b=[[-1, -5], [-3, -1]]
    c=[[-3,  2], [ 3,  1]]
    d=[[-2, -4], [ 4, -2]]
    e=[[ 7,  2], [-1, -2]]

    segments = [a,b,c,d,e]

    expect(intersections segments).to.eql [
      { intersection: [5*5/17-4, 7*5/17-4], segments: [a, b] }
      { intersection: [-1.5, -2+1/6], segments: [b, d] }
      { intersection: [ 0, -1.5], segments: [a, c] }
    ]



