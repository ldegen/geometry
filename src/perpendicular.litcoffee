
## Constructing a point on a perpendicular

Given a line through two points `s` and `e`,
we want to be able to calculate a point `p` with the
following properties:

  - `x` resides on perpendicular to `s—e` going through `s`

  - we want `|p - s| = |d|` for some given scalar `d`

  - if `d` is positive, `p` should be left of `s—e`, otherwise
    it should be right

So how do actually calculate that point?

Let `a = e - s` and. We start by looking for a unit vektor `x`
that points into the right direction. So for starters, we need

  \<x,a\> = 0

We also want `x` to point left for positive `d`s.

Turns out that `x = (a2,-a1) / |a|` fits our bill snuggly.  
All that is left is multiplying the desired  ength.

    module.exports = ([s1,s2], [e1,e2], w)->
      a1 = e1 - s1
      a2 = e2 - s2
      len = Math.sqrt(a1*a1+a2*a2)
      if len > 0
        x1 = a2 / len
        x2 = -a1 / len
        [s1 + w*x1, s2 + w*x2]
      
