## The trapezoid induced by a single bone

The bone itself is perpendicular to the two parallel sides
of the trapezoid.  Each point is constructed by picking an end-point of
the bone (start or end) and then a side (left or right).  Then the point
we are looking for is on line perpendicular to the bone through the
choosen end. Its distance is the width associated with that end point.
We assume the direction of the perpendicular to point left with regard
to the bone. To construct the point on the right, use a negative
"distance".

We created a helper function construct the four points

    perpendicular = require('./perpendicular')

With this little helper, we can easily define our trapezoid:

    elm = (i)->(arr)->arr[i]

    module.exports = (bone, { startPoint = elm(0),
                              endPoint = elm(1),
                              startWidth=elm(2),
                              endWidth=elm(3)
                            }={}) ->
      sp = startPoint(bone)
      ep = endPoint(bone)
      sw = startWidth(bone)
      ew = endWidth(bone)
      [
        perpendicular(sp,ep,sw)  # start left
        perpendicular(ep,sp,-ew) # end left
        perpendicular(ep,sp,ew)  # end right
        perpendicular(sp,ep,-sw) # start right
      ]
