## Connect Two Open Contour Lines

This function will take two lists of vertices and stitch them together
in a …meaningful… façon. The general assumption here is that both lists
are the vertices of open polygonal contour lines and that the end of the
first line needs to be somehow connected to the start of the second one.

    connect = (firstList, secondList)->

We make this *very* simplistic for now. We pick the last segment of the
first list and the first segment of the second list.

      [prefix...,e1,e2] = firstList
      [s1,s2,suffix...] = secondList

If they are on intersecting lines, insert the intersection point.
This works like the 'trim-both' operation in classic 2d CAD applications.

      cs = coefficients([e1,e2],[s1,s2])

      if cs?
        p = vInterpolate(e1,e2)(cs[0])
        # would have been equivalent:
        # p = vInterpolate(s1,s2)(cs[1])
        [prefix...,e1, p, s2, suffix...]

Otherwise, don't.
Just concatenate both lists. We assume that the renderer will
draw a straight line between e2 and s1

      else
        [firstList..., secondList...]

