## Comparing coordinate pairs

  
Our scanline is vertical and moves from left to right.
So we prioritize our events on their x coordinates. But
we also use the y coordinate as tie-breaker.

    comparePoints= ([x1,y1],[x2,y2])->
      dx = x1-x2
      if dx is 0 then y1-y2 else dx

We use the same comparator to determine which of the two
end-points of a segment is 'left', and which one is 'right'.

    leftEndPoint = ([a,b])-> if comparePoints(a,b) > 0 then b else a
    rightEndPoint = ([a,b])-> if comparePoints(a,b) > 0 then a else b

## Comparing active line segments

A line segment is active if it has a non-empty intersection with 
the scanline. We will keep active segments in a binary search tree
sorted by their vertical position at which they touch the scanline.
Though the exact position will change as the scanline moves,
the ordering should remain stable, unless of course we have a pair
of intersecting line segments, which we will handle below.

Keeping the active segments ordered is important, as it helps us
to narrow down the pairs we have to check for intersections 
quite a bit. You can see it like this: If there is an intersection
between line segments a and b than at some point *before* that
intersection both lines *must* have been adjacent in our search
tree. Following an idea I found in Sedgewick's Algorithms, we
choose a generalized compare function for our tree that will
detect intersections as exactly those situations where two active
segments cannot be compared.

    {cmpV} = require './scan-line-order'

Intersecting pairs will be detected either when inserting or when
rearanging the tree after removal of a segment.  As Sedgewick points
out, some extra care has to be taken to account for the fact that our
"generalized order relation" is not transitive.  This basically means
that whenever the structure of the tree changes, we have to explicitly
compare nodes that become adjacent to make sure the ordering is still
consistent.  This is the main reason why I choose to implement the tree
myself.
    
    Tree = require './binary-search-tree'

Because I am lazy, this tree is not self-balancing. 
I think that could be added, but would also involve more explicit
comparisons.




## Types of events

Events contain x and y coordinates, an event type
and one or more segments. There are three types of 
events:

- The start of a segment
    
    startEvent = (s)->[leftEndPoint(s)..., 's', s]

- The end of a segment

    endEvent = (s)->[rightEndPoint(s)..., 'e', s]

## Handling intersections

In most implementations of the Bentley-Ottmann-Algorithm,
there is a third event type used for intersections.
We take a different approach, also inspired by Sedgewick's book:

Whenever we detect an intersection, we "split" both lines
at the intersection point. Within the tree, both segments are replaced
with their respective left "half". We add two end events and two start
events to the queue, all four at the point of intersection.

With most other implementations, there is some book keeping going on
that makes sure that intersections are not detected twice.
We do not need to worry about this, because after processing the
intersection the first time, it is gone. We do however have
to add some logic to the scan-line-ordering that makes sure that
segments that share a vertice are still comparable.

## The actual algorithm

As input, we expect a list of line segments
Each segment is an array of at least two elements.
Those are the coordinate arrays of the two end-points.
The algorithm will ignore any remaining elements.
It shall not modify the input.

    module.exports = (segments)->

The following steps are taken from the wikipedia article but
modified slightly to remove some of the assumptions of the original
algorithm

Initialize a priority queue of potential future events. 

      queue = Queue (comparePoints)

Initially, the queue contains an event for each of the endpoints
of the input segments.
    
      for s in segments
        queue.push startEvent s
        queue.push endEvent s

We use a binary search tree to track the 'active' line segments.
A line segment is active if it touches or crosses the scanline.
We want the active segments to be always sorted by the y-position
at which they currently intersect the scanline. 
Of course, these positions will change as the scanline moves.
However, the ordering will remain stable (modulo insert/remove)
*unless two lines are crossing*. 

To achieve this, we always use the latest event related to a line
segment as its key. 
Initially, T is empty.

      activeSegments = Tree (a,b) -> a[1]-b[1]

Keep going for as long as there are events in the queue:
    
      while not queue.isEmpty()
      
Extract the left-most event from the queue and process it according
to its type.
      
        [evX,evY,evType,evSegments...] = event = queue.pop()

        switch evType

### Case 1: Start point of a new line segment

When the scanline encounters the left endpoint of a new segment
insert it into to the active segments. 

          when 's'
            newSegment = evSegments[0]
            activeSegments.add event

Look for the two active segments that are immediately above and below
the newly inserted segment. 

            above = activeSegments.itemBefore(event)?.slice(3) ? []
            below = activeSegments.itemAfter(event)?.slice(3) ? []

If they cross the new segment, create crossing-events to the queue
accordingly.

            for segment in above when intersect segment, newSegment
              queue.push intersectionEvent segment, newSegment
            for segment in below when intersect newSegment, segment
              queue.push intersectionEvent newSegment, segment



### Case 2: End-point of an active line segment

When the right end-point of a line segment is encountered
      
          when 'e'
            endingSegment = evSegments[0]

determine the active segments immediatly above and below before
removing the ending segment

            above = activeSegments.itemBefore(event)?.slice(3) ? []
            below = activeSegments.itemAfter(event)?.slice(3) ? []

            activeSegments.remove event
