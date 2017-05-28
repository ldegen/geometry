
## creating a skin for a skeleton

In our first step, our turtle produces what I call the *skeleton* for our
graphic. Imagine the lines drawn by the turtle as the bones. We now want to
flesh out these bones by giving them a dynamic width and we want to calculate a
contour line that I call skin.

But first have a closer look at our skeleton and the bones it is made
of.  If we assume that the turtle never does a "f" movement, then all
bones are connected. (For the stellasplendicon this is essentially
always the case)

Further, the bones have a defined direction: The turtle moves from A to
B, thus we can call A the start and B the end of the bone.  This is
great, because it makes it easier to describe stuff.  For instance, if a
bone has a defined direction, we can talk about the left or the right
side of a bone.

Another important property of our bones is that they are labeld with two
scalar width values. These define how thick the flesh on that bone is at
its start and at its end.

Finally and importantly, the way the turtle moves induces a tree, with
the initial position of the turtle being the root.

So... what datastructure to represent our skeleton?  How do we best
exploit the tree-ness of its topology?  It turns out to be benefitial to
moreless ignore the joints and instead build a tree where each node
represents a bone.  In a way this dual to the graph we intuitivly
imagine when we think of bones and joints. But as we shall see it makes
things very easy.

Each bone-node should have a start and end point as well as the start
and end radii (a.k.a. width). And finally, it should hold references to
its children.

There are several ways to do this in javascript, and I frankly don't
care about the details right now.

Just define some accessors to extract the information we need.  I will
probably revise this once the turtle api stabelizes

    startPoint = (b) -> b[0]
    endPoint   = (b) -> b[1]
    startWidth = (b) -> b[2] ? 0.5
    endWidth   = (b) -> b[3] ? 0.5

We need the children to be sorted clockwise with respect to the parent
bone. Check the `./compare-clockwise.litcoffee`-module for the
details on how to do that.

    compare = require('./compare-clockwise')

Here, we just use that module to sort the children on the fly.

    children   = (bone) ->
      bone[4]?.slice()?.sort(compare(bone)) ? []

If our skeleton consisted of a single bone then its skin would be a
trapezoid.  The bone itself is perpendicular to the two parallel sides
of the trapezoid.  Each point is constructed by picking an end-point of
the bone (start or end) and then a side (left or right).  Then the point
we are looking for is on line perpendicular to the bone through the
choosen end. Its distance is the width associated with that end point.
We assume the direction of the perpendicular to point left with regard
to the bone. To construct the point on the right, use a negative
"distance". We created a helper function for this in another module:

    perpendicular = require('./perpendicular')

With this little helper, we can easily define our trapezoid:

    trapezoid = (bone) ->
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

To create the skin of a (sub-)tree of bones we start with this trapezoid, but
combine it with the skins of the bone's childrens' subtrees.

    skin = (bone)->
      [t1,t2,t3,t4] = trapezoid(bone)
      subtreeSkins = children(bone).map(skin)
      [[t1,t2], subtreeSkins..., [t3,t4]].reduce connect

This was way to easy. Obviously, the secret sauce must be in the `connect`
function. Check this module for details:

    connect = require('./connect-contours')

That's it. We are done.
