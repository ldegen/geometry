

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

    compareClockwise = require "./compare-clockwise"

    module.exports = (parent,{startPoint=elm(0),endPoint=elm(1)}={})->

The actual work happens in a lower level function.
Please refer to compare-clockwise.litcoffee for details

      p = startPoint(parent)
      m = endPoint(parent) # same as childrens' startPoint
      cmp = compareClockwise(p, m)
      (childA,childB)->
        a = endPoint(childA)
        b = endPoint(childB)
        cmp a, b

