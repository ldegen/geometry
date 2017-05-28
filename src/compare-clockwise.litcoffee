
## Ordering bones at a joint in clockwise fashion


When calculating the skin for our skeleton, we represent the skeleton
as a tree of bones. The root of the tree is the start position of the
turtle. At each joint, there is one parent bone and the remaining bones
are the children of that bone. For the skinning algorithm to work,
those children need to be in clockwise order with regard to the parent
bone.

Thus, we need to define the comparator function relative to the parent 
bone.

Note that we quietly assume that the endpoint of parent and the
start points of the children are all the same. The whole comparison
wouldn't make much sense otherwise.

Note that we also assume that there is no child in the exact
oposite direction of the parent. The behaviour in this case is
undefined. Which is no problem in our application.

    elm = (i)->(arr)->arr[i]

    ccw = require("./ccw")

    module.exports = (parent,{startPoint=elm(0),endPoint=elm(1)}={})->(childA,childB)->
      p = startPoint(parent)
      m = endPoint(parent) # same as childrens' startPoint
      a = endPoint(childA)
      b = endPoint(childB)

Now, imagine a line through the parent bone. Either both children are on
the same side, or they are on different sides.  If they are on different
sides, the one on the left side comes first.


      # positive values indicate counter clockwise movement
      # i.e. left side of parent.
      ca = ccw(p,m,a)
      cb = ccw(p,m,b)

      if ca*cb < 0 # different sign, ergo different sides
        if ca > 0 or cb < 0 then -1 else 1

Otherwise, i.e. if both children are on the same side, we need another
comparison.
      
      else ccw(m,a,b) # negative --> clockwise --> a is left
