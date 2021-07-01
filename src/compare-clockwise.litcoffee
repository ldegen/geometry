This function can be used as a comparator to sort a number of nodes
adjacent to some given point ``m`` in clockwise order relative to some
reference point ``p``.

Imagine you are traversing the edges of a planar graph. You arive at ``m``
("mid point") via some other point ``p`` ("parent"), and you now want to
visit the other points ("children") connected to ``m`` in clockwise order.
This HOF answers the question given ``p`` and ``m`` as above, which of two
given children ``a`` and ``b`` should be visit first. In particular, you
can use it with something like ``Array.prototype.sort`` to sort an
array of children.

The implementation works like this:

Imagine a line through the `p` and `m`. Either both children are on
the same side, or they are on different sides.  If they are on different
sides, the one on the left side comes first.

    ccw = require("./ccw")
    identity = (x)->x

    module.exports = (p,m,vpos=identity)->
      p=vpos p
      m=vpos m
      (a,b)->

        a = vpos a
        b = vpos b
        # positive values indicate counter clockwise movement
        # i.e. left side of parent.
        ca = ccw(p,m,a)
        cb = ccw(p,m,b)

        if ca*cb < 0 # different sign, ergo different sides
          if ca > 0 or cb < 0 then -1 else 1

Otherwise, i.e. if both children are on the same side, we need another
comparison.

        else ccw(m,a,b) # negative --> clockwise --> a is left
