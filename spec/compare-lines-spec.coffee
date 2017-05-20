describe "The scan-line-order relation", ->

  {cmpH, cmpV} = require "../src/scan-line-order"

  # NOTE: I try to add more systematic test coverage
  #       for an explanation of the choice of test cases
  #       see ./intersect-spec.coffee
  #
  #       The core idea is to see the intersection test as a special
  #       application of the order relation that we want to define.
  #       Two lines intersect if and only if they cannot be compared.
  #
  #       There are a couple of questions to be asked, though:
  #
  #       - What about segments that share one end point?
  #
  #       - Or what if the end point of one segment lies on the other
  #         segment?
  #
  #       In both cases, the basic relation as defined by Sedgewick
  #       would classify the pair as intersecting.
  #       But *I* want the first case to be handled differently.
  #
  #       Oh, and don't get me started on the colinear cases...
  #
  #
  describe "for non-colinear cases", ->
    # Assume both segments are part of crossing lines.
    # Then there is a crossing point of those two lines.
    # For each segment, we can distinguish 5 equivalence classes
    # based on how the two end points are positioned with respect
    # to the crossing point. (both left, one left, left-and-right, one right, both right)
    # So we have a total of 25 cases to cover.
    #
    # But. There are a couple of cases where the behaviour is irrelevant.
    # We only need to able to compare two lines that are active (i.e. touched by the scan line)
    # at the same time. Plus, if the start point of one line and
    # the end-point of the other line coincide, we can assume that
    # the first line ends before the second one starts, so the lines
    # are actually not active at the same time.
    #
    # To make things easier to read, we use 3x3 square grid of
    # predefined end-points. The grid is rotated by 45° ccw.
    #
    #       A3
    #      /  \
    #    A2    B3
    #   /  \  /  \
    # A1    B2    C3
    #   \  /  \  /
    #    B1    C2
    #      \  /
    #       C1

    A1=[-2,0]; A2=[-1,-1]; A3=[0,-2]
    B1=[-1,1]; B2=[0,0]; B3=[1,-1]
    C1=[0,2]; C2=[1,1]; C3=[2,0]

    it "works as expected", ->
      #       A3               A3               A3               A3
      #      /                /                /                /
      #    A2               A2               A2               A2    B3         A2    B3
      #                    /                /                /        \       /        \
      #                  A1               A1    B2         A1          C3   A1          C3
      #                                           \
      #    B1               B1                     C2
      #      \                \
      #       C1               C1
      #expect(cmpH [A2,A3], [B1,C1]).to.be.undefined # we officialy don't care
      expect(cmpV [A2,A3], [B1,C1]).to.be.below 0 # the upper segment wins.

      #expect(cmpH [A1,A3], [B1,C1]).to.be.below 0 # same as above, we don't care
      expect(cmpV [A1,A3], [B1,C1]).to.be.below 0 # again, the upper one wins.

      expect(cmpH [A1,A3], [B2,C2]).to.be.below 0 # B2-C2 is "right" of "A1-A3"
      expect(cmpV [A1,A3], [B2,C2]).to.be.below 0 # same thing.

      expect(cmpH [A1,A3], [B3,C3]).to.be.below 0 # same as above
      #expect(cmpV [A1,A3], [B3,C3]).to.be.below 0 # don't care

      expect(cmpH [A1,A2], [B3,C3]).to.be.below 0 # obvious
      #expect(cmpV [A1,A2], [B3,C3]).to.be.below 0 # no overlapping projection


      #       A3               A3               A3               A3               A3
      #      /                /                /                /  \                \
      #    A2               A2               A2               A2    B3         A2    B3
      #                    /                /  \             /        \       /        \
      # A1               A1               A1    B2         A1          C3   A1          C3
      #   \                \                      \
      #    B1               B1                     C2
      #      \                \
      #       C1               C1
      #expect(cmpH [A2,A3], [A1,C1]).to.be.below 0
      expect(cmpV [A2,A3], [A1,C1]).to.be.below 0

      #expect(cmpH [A1,A3], [A1,C1]).to.be.below 0 # see above: end before start
      expect(cmpV [A1,A3], [A1,C1]).to.be.below 0

      expect(cmpH [A1,A3], [A2,C2]).to.be.undefined
      expect(cmpV [A1,A3], [A2,C2]).to.be.undefined
      
      expect(cmpH [A1,A3], [A3,C3]).to.be.below 0
      #expect(cmpV [A1,A3], [A3,C3]).to.be.below 0 #as above

      expect(cmpH [A1,A2], [A3,C3]).to.be.below 0
      #expect(cmpV [A1,A2], [A3,C3]).to.be.below 0


      #                                                          A3               A3
      #                                                            \                \
      #          B3               B3         A2    B3               B3               B3
      #         /                /             \  /                /  \                \
      # A1    B2         A1    B2               B2               B2    C3         B2    C3
      #   \                \  /                /  \             /                /
      #    B1               B1               B1    C2         B1               B1
      #      \                \
      #       C1               C1
      expect(cmpH [B2,B3], [A1,C1]).to.be.above 0
      expect(cmpV [B2,B3], [A1,C1]).to.be.below 0

      expect(cmpH [B1,B3], [A1,C1]).to.be.undefined
      expect(cmpV [B1,B3], [A1,C1]).to.be.undefined
        
      expect(cmpH [B1,B3], [A2,C2]).to.be.undefined
      expect(cmpV [B1,B3], [A2,C2]).to.be.undefined

      expect(cmpH [B1,B3], [A3,C3]).to.be.undefined
      expect(cmpV [B1,B3], [A3,C3]).to.be.undefined

      expect(cmpH [B1,B2], [A3,C3]).to.be.below 0
      expect(cmpV [B1,B2], [A3,C3]).to.be.above 0


      #                                                          A3               A3
      #                                                            \                \
      #                                      A2                     B3               B3
      #                                        \                      \                \
      # A1          C3   A1          C3         B2    C3               C3               C3
      #   \        /       \        /             \  /                /
      #    B1    C2         B1    C2               C2               C2               C2
      #      \                \  /                /                /                /
      #       C1               C1               C1               C1               C1

      expect(cmpH [A1,C1], [C2,C3]).to.be.below 0
      #expect(cmpV [A1,C1], [C2,C3]).to.be whatever
      
      expect(cmpH [A1, C1],[C1,C3]).to.be.below 0
      #expect(cmpV [A1, C1],[C1,C3]).to.be.below 0

      expect(cmpH [A2, C2], [C1,C3]).to.be.undefined
      expect(cmpV [A2, C2], [C1,C3]).to.be.undefined

      #expect(cmpH [A3,C3], [C1,C3]).to.be.egal
      expect(cmpV [A3,C3], [C1,C3]).to.be.below 0

      #expect(cmpH [A3,C3], [C1,C2]).to.be.egal
      expect(cmpV [A3,C3], [C1,C2]).to.be.below 0
      


      #                                                          A3               A3
      #                                                            \                \
      #                                      A2                     B3               B3
      #                                        \
      # A1          C3   A1          C3         B2    C3               C3
      #   \        /       \        /                /                /
      #    B1    C2         B1    C2               C2               C2               C2
      #                          /                /                /                /
      #                        C1               C1               C1               C1
      expect(cmpH [A1,B1], [C2,C3]).to.be.below 0
      #expect(cmpV [A1,B1], [C2,C3]).to.be.below 0
      
      expect(cmpH [A1,B1], [C1,C3]).to.be.below 0
      #expect(cmpV [A1,B1], [C1,C3]).to.be.below 0

      expect(cmpH [A2,B2], [C1,C3]).to.be.below 0
      expect(cmpV [A2,B2], [C1,C3]).to.be.below 0

      #expect(cmpH [A3,B3], [C1,C3]).to.be.egal
      expect(cmpV [A3,B3], [C1,C3]).to.be.below 0

      expect(cmpH [A3,B3], [C1,C2]).to.be.egal
      expect(cmpV [A3,B3], [C1,C2]).to.be.below 0
      



  describe "for colinear cases", ->
      #  ╔════════╦═══════╦══════╦═════╦══════╦═══════╦════════╗
      #  ║ └─┘┌─┐ ║ └─┼─┐ ║ └┬┴┐ ║ ├—┤ ║ ┌┴┬┘ ║ ┌─┼─┘ ║ ┌─┐└─┘ ║
      #  ╚════════╩═══════╩══════╩═════╩══════╩═══════╩════════╝


    #expect(intersect [-3,1], [-1,0], [1,-1], [3,2]).to.be.false
    #expect(intersect [-1,0], [1,-1], [1,-1], [3,2]).to.be.true
    #expect(intersect [-3,1], [1,-1], [-1,0], [3,2]).to.be.true
    #expect(intersect [-1,0], [1,-1], [-1,0], [1,-1]).to.be.true
    #expect(intersect [-1,0], [3,-2], [-3,1], [1,-1]).to.be.true
    #expect(intersect [1,-1], [3,-2], [-1,0], [1,-1]).to.be.true
    #expect(intersect [1,-1], [3,-2], [-3,1], [-1,0]).to.be.false
