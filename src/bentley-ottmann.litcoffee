## Common helper routines

    {vInterpolate,coefficients} = require "./common"

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

## Data Structures

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

Another thing that we need is a priority queue. We do not care much
about its implementation details. We hide those behind a simplistic API.

    FPQ = require 'fastpriorityqueue'
    Queue = (cmp)->
      impl = new FPQ (a,b)->cmp(a,b)<0

      isEmpty: -> impl.isEmpty()
      size: -> impl.size()
      push: (v)-> impl.add v
      pop: -> impl.poll()
      peek: -> impl.peek()




## Scanline Events

Events contain x and y coordinates, an event type
and the index of the associated segment in the input array. 
So there are two types of events:

- The start of a segment
    
    startEvent = (s,i)->[leftEndPoint(s)..., 's', i]

- The end of a segment

    endEvent = (s,i)->[rightEndPoint(s)..., 'e', i]

## Handling intersections

In most implementations of the Bentley-Ottmann-Algorithm,
there is a third event type used for intersections.
We take a different approach, also inspired by Sedgewick's book:


When the binary tree detects a pair of keys that cannot be compared,
it removes any nodes with this keys and reports the edge pair.

    deleted = []

    handleIntersection = (segments,queue) -> (a,b)->

We determine the point at which the two segments intersect

      [λ,μ] = coefficients a.key, b.key
      p = vInterpolate(a.key...)(λ)

Next, we "split" both line segments at at the intersection point and generate
four new segments.

      newSegments = [
        [a.key[0],p]
        [p, a.key[1]]
        [b.key[0],p]
        [p, b.key[1]]
      ]

We generate start and end events for the new segments and
add them to the event queue. 
We also push the new segments into our input array,
so we can refer to them later
(TODO: not nice, solve this differently)

      for s in newSegments
        sx = segments.length
        segments.push s
        queue.push startEvent s, sx
        queue.push endEvent s, sx



We do want no further processing of the old segments.
Since it is not feasable to remove random events from the queue, 
we blacklist the old segments. Thus, when the scan line touches
an event that refers to them, this event is silently skipped.
      
      deleted[a.value]=true if a.value?
      deleted[b.value]=true if b.value?
  

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

      queue = Queue comparePoints

      intersectionFound = handleIntersection segments, queue

Initially, the queue contains an event for each of the endpoints
of the input segments.
    
      for s,i in segments
        queue.push startEvent s,i
        queue.push endEvent s,i

Create the BST to track the segments currently intersected by the scan line.
We use the "generalized order relation" suggested by Sedgewick (see above).

      activeSegments = Tree cmpV

Now, we are entering the main loop. The following steps are repeated
as long as there are events in the queue.
    
      while not queue.isEmpty()
      
Extract the left-most event from the queue and process it according
to its type, skipping any events that belong to deleted segments
      
        [evX,evY,evType,sx] = event = queue.pop()
        
        continue if deleted[sx]

        s = segments[sx]
        console.log "-----"
        console.log "event", event
        

        switch evType

### Case 1: Start point of a new line segment

When the scanline encounters the left endpoint of one or more
segments we insert those segments into our active set

          when 's'
            activeSegments.insert s, sx, intersectionFound

### Case 2: End-point of an active line segment

When the right end-point of one or more line segments is encountered
we remove those segments from our active set
      
          when 'e'
            activeSegments.remove s, intersectionFound

And that's it. The actual "smartness" is in the implementation of our search
tree and the "generalized order relation".
