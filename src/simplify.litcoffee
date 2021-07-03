
    insertIntersections = require "./insert-intersections"
    ccw = require "./ccw"
    redundance = require "./redundance"
    conditioner = require "./conditioner"
    snap = require "./snap"
    Ring = require "./ring"
    OutputRing = require "./output-ring"
    {closeRing} = require "./common"
    visualize = require "./visualize"
    {writeFileSync} = require "fs"

## Input and output

We expect the input to be an array of array of arrays of floats. The
convention is the same used in GeoJSON to describe a geometry of type
`Polygon`.  The inner most arrays are coordinate pairs or *vertices*.
Polygons are described using a list of edge *rings*. Each ring is a list
of vertices where the first and the last vertex have exactly the same
coordinates.  This convention may seem a bit strange at first, but it
has its benefits. We will use it for both our input and our output.

One of the rings is the *outline* of the polygon, the others are
*holes*.  We do not make assumptions about the order of the input rings,
but we guarantee that in our output the first ring will be the outline.



    module.exports = (rings0, options={})->

## Building a "planar" graph


We start by detecting all self- and cross intersections
and inserting corresponding vertices into the input rings.
Then we create a mesh datastructure (convert rings to lists
of vertex indices), collapsing identical (or very close) vertices
on the fly.

      planarRings = insertIntersections rings0
      {vertices, edges:rings1} = snap radius:options.snapRadius, removeDuplicateEdges: options.snapRemoveDuplicateEdges, edges:planarRings


      #console.log "vertices:"
      #for coords, vId in vertices
      #  console.log vId, coords

      redundanceInfo = undefined
      if options.ignoreRedundantEdges
        redundanceInfo = conditioner redundance rings1
        #console.log "redundance", redundanceInfo
        for ringId,{flip} of redundanceInfo when flip
          #console.log "flipping ring #{ringId}"
          rings1[ringId].reverse()


      #console.log "input rings:"
      #for vIds,ringId in rings1
        #console.log ringId,vIds

## Relationship between concepts: rings, paths, edges

An edge can be seen as a path of length 1. Our input and output rings are
(circular) paths. For our purposes the GeoJSON represenation is not
optimal. For our internal model, we strip of the redundant last vertex
and wrap the array in a helper structure that allows for more
"ring-like" navigation.


      rings = rings1.map ([vIds...,lastVid])->Ring vIds
      if options.debug
        writeFileSync "/tmp/debug.svg", visualize {vertices,rings,redundanceInfo}

      #console.log "input rings after preprocessing"
      #for ring,ringId in rings
        #console.log ringId, ring.data


## Identify all Joints

We use the term *joint* to refer to any vertex that occurs more than
once in our input. This may happen if

- the vertex is the first and the last of an input ring. We removed
  the last vertex from our internal model, but the first vertex is
  still relevant as a joint, as we will see in a bit.

- the vertex occurs more than once in a single ring.

- the vertex occurs in more than one ring.

The last two cases are of particular interest, because they mark
situations where one ring either touches or intersects itself or
other rings. Our goal is to turn all the intersections into tangential
cases.

We create a lookup table of all joints, using their vertex id as key.
For starters, we run through our rings and record all vertex occurrances.
An occurrance is a pair (ring index,position in ring).

      lookup = {}
      for ring, ringIndex in rings
        for vId, positionInRing in ring.data
          entry=lookup[vId]?={occurrances:[],outputRings:{}}
          entry.occurrances.push {ringIndex,positionInRing}

Now we have a reverse lookup for all vertices. But we are only
interested in joints, so delete all entries that are not for joints.
Remember: a vertex is a joint if it occurs at least twice in the input.
Since we removed the redundant last vertex from the rings in our
internal model, we need to keep in mind, that for each ring, the first
vertex is a joint aswell, even if there are no further occurrances.

      for vId, {occurrances} of lookup
        unless occurrances.length > 1 or occurrances[0].positionInRing is 0
          delete lookup[vId]

Finally, we can define a function that efficiently determines if a
given vertex is a joint.

      isJoint = (vId)->lookup[vId]?

## Arcs

An arc is a special kind of path that stars and ends at a
joint, but otherwise does not contain any joint.  So in our case, any
arc must be a contiguous subset of some input ring.  We can uniquely
identify an arc using a ringIndex an the start position of the arc
within this ring. The enposition can always be determined by doing a
forward search for the next vertex in the ring that is a joint.

      goto = ({ringIndex,positionInRing})->rings[ringIndex].set(positionInRing)

      startJoint = ({ringIndex,positionInRing})->
        rings[ringIndex](positionInRing)

      endOfArc = ({ringIndex, positionInRing})->
        ringIndex:ringIndex
        positionInRing:rings[ringIndex]
          .set positionInRing+1
          .search isJoint
          .position()


      endJoint = (arc)->
          startJoint(endOfArc(arc))

      edgeKey = (a,b)->
        key = if a<b then [a,b] else [b,a]

      arcRedundant = (arc)->
        if options.ignoreRedundantEdges
          ring = goto(arc)
          key = edgeKey( ring(),ring(1))
          redundanceInfo[arc.ringIndex].skip[key]



## Why are arcs interesting?

All the input rings are composed of arcs. So are the output rings.
In fact, we will use the same arcs, we will just have to rearrange
them. We define a little helper that will allow us to trace out the
coordinates of the vertices of a given sequence of arcs.

So by processing all those occurrances, we process all arcs,
i.e. the complete input.  This is the reason why we defined that the
first vertex of each ring is a joint, even if it only occurrs once.
There needs to be at least one joint in any ring.  Otherwise, we would
loose track of those rings that do not contain any intersection.
the output. However, we do need to rearrange those arcs in a way that
the resulting rings touch but do not intersect.

Processing all input means processing all arcs.  To know when we are
done, we need to keep track of the number of arcs that still need to be
processed. There is exactly one arc for each occurrance of a joint and
vice versa. In fact, we identify joint occurrances and arcs.

To find an arc that hasn't been processed, we can actually just do a linear
search through all joint occurrances and look for one that has not been
marked. It is important to realize that we are doing this only once per
output ring, so we should not invest too much overhead to create auxillary structures.
My current idea is to keep them in a single list and to keep track of the
position in this list that was last reported unprocessed -- everything before
this position is *known* to be processed. The list can also be ordered by some
criterion which may come in handy later. (Think: containment etc.)

      arcs = []
      arcsCursor = 0
      for vId, {occurrances} of lookup
        arcs.push occurrances...

      pickUnusedArc = ->
        #console.log "pick unused arc"
        #console.log "arcsCursor", arcsCursor
        #console.log "arcs:",arcs
        while arcsCursor < arcs.length
          arc = arcs[arcsCursor++]
          return arc if not arc.processed and not arcRedundant arc



The general structure of the simplification process works like this:

      run = ->
        outputRings = []
        arc = pickUnusedArc()
        while arc?
          #console.log "start on ring #{arc.ringIndex} at position #{arc.positionInRing} vertex #{startJoint arc}"
          outputArcs = []
          visitedVertices = []

          endVertex = null
          while true
            arc.processed=true
            outputArcs.push arc
            visitedVertices.push startJoint arc
            {ringIndex,positionInRing} = endOfArc(arc)
            endVertex = rings[ringIndex](positionInRing)
            #console.log "follow arc to vertex", endVertex
            while (q = visitedVertices.indexOf endVertex) isnt -1
              circle = outputArcs.slice q
              #console.log "circle closed:",circle
              outputRings.push OutputRing circle, rings, ((vId)->vertices[vId]), isJoint
              outputArcs = outputArcs.slice 0,q
              visitedVertices = visitedVertices.slice 0,q
            if visitedVertices.length == 0
              #console.log "stack empty"
              break
            else
              #console.log "looking for an arc to continue on"
              arc = pickNextArc ringIndex, positionInRing
              #if arc?
              #  console.log "continue on ring #{arc.ringIndex} at vertex #{startJoint arc}"
              #else
              #  console.log "no continuation found"
          #console.log "looking for an other unused arc"
          arc = pickUnusedArc()


        outputRings



Pick some arc that has not been processed yet. Append it to the
current output ring. Then chose another arc that starts at the
end joint of the first arc, and so on until we arrive at the vertex
we started from (i.e. the output ring is complete).
Then start with a new output ring. Repeat until there are no arcs left.

## Avoid intersections

The trick is to make sure that we pick the arcs in the right order, so
that none of the joints are intersections.

But when is a joint an intersection?  When I connect two arcs (one
inbound, one outbound) at a joint, I split the plane into two parts: one
left, one right.  If I then connect two more arcs at the same joint, one
on the left and one on the right, I create an intersection.
This is what we need to avoid, which, as it turns out, is quite simple.

One obvious necessary criterion is this: when we split the plane, we
need to leave a matching number of inbound and outbound arcs on each
side. Otherwise, we would create a situation where it is impossible to
connect two remaining arcs without creating an intersection with the two
arcs we just joint.

Let's assume (for contradcition) that we adhered to that criterion but
still run into such a situation.  So we arrive at a joint on one side of
an already connected pair of arcs, and there is no "unused" outbound arc
on that same side. Nope, not possible, as it directly contradicts our
assumption. So if we adhere to the necessary criterion, there willwE
always be an outbound arc left on the same side.  It can even be shown
(I don't know how :-) ) that there will always be an outbound arc that
we can continue on without violating the necessary criterion.

So: the necessary criterion is in fact also sufficient. Beautiful.

We need two little helpers. `flatmap` is just what the name suggests.
`theta` calculates the angle between the positive x axis
and the line going from `fromId` to `toId` (both being vertex ids).

      flatmap = (arr, transform) -> [].concat((arr.map(transform))...)
      theta = (fromId)->(toId)->
        [fromX,fromY] = vertices[fromId]
        [toX,toY] = vertices[toId]
        Math.atan2(toX-fromX,toY-fromY) # * 180 / Math.PI

For all joints, we create a list of adjacent edges, both in- and
outbound.  We order this list in clockwise order (it does not matter
where we start), and then wrap this list into our ring datastructure.
Note that inbound and outbound edges have different structures.
For the outbound, we reference the occurrance as it *is* the arc
that starts with that edge. For the inbound edge we need to separately
track wether it has been used (processed) before.

      compareEdges = (a,b)->
        if a.peer isnt b.peer
          a.theta - b.theta
        else if a.direction is "inbound" and b.direction is "outbound"
          -1
        else if b.direction is "inbound" and a.direction is "outbound"
           1
        else if a.direction is "inbound"
          a.ringIndex - b.ringIndex
        else
          b.ringIndex - a.ringIndex


      for vId, entry of lookup
        edgeTheta = theta vId
        occurrances = entry.occurrances
        adjacentEdges = flatmap occurrances, (occurrance)->
          {ringIndex, positionInRing} = occurrance
          ring = rings[ringIndex]
          prev = ring.set(positionInRing - 1)
          next = ring.set(positionInRing + 1)

          [
            direction: "inbound"
            ringIndex: ringIndex
            positionInRing: prev.position()
            theta: edgeTheta prev()
            peer: prev()
          ,
            direction: "outbound"
            ringIndex: ringIndex
            positionInRing: positionInRing
            occurrance: occurrance # FIXME: redundant?
            theta: edgeTheta next()
            peer: next()
          ]

        .filter ({peer,ringIndex})->
          key = edgeKey(peer,vId)
          not options.ignoreRedundantEdges or not redundanceInfo[ringIndex].skip[key]

        .sort compareEdges

We wrap the adjacent edges in a Ring data structure. The word has
nothing to do with our rings, think of it more like a ring buffer. We
will use this to iterate the edges in clockwise/counter-clockwise order
starting at some incoming edge.

        entry.adjacentEdges = Ring adjacentEdges


Now, if we arrive at a joint `vId` we can do the following to pick a
"good" next arc:

      pickNextArc = (ringIndex, positionInRing)->
        vId = rings[ringIndex](positionInRing)
        {adjacentEdges} = lookup[vId]

Within the adjacent edges of `vId`, find the inbound edge we arrived from

        pos = rings[ringIndex]
          .set positionInRing - 1
          .position()

        #console.log "vId", vId
        #console.log "adjacent Edges", adjacentEdges.data
        #console.log "ringIndex", ringIndex
        #console.log "position", pos
        start = adjacentEdges
          .search (edge)->
            ( edge.ringIndex is ringIndex and
              edge.direction is "inbound" and
              edge.positionInRing is pos
            )
        #console.log "arriving at vertex #{vId} via #{start().peer} on ring #{ringIndex}"

Next, we look for matching outbound edge, i.e. one that

- does not cross any already connected edge pair
- leaves an equal number of innound and
  outbound edges on each side.

This can be done iterating the edges first in clockwise, then
in counter-clockwise order, starting from the edge we arrived from.
On both directions, we stop when we hit an edge that has already been used.
We use a counter to keep track of the edges we come accress. We increment it
for each inbound edge and decrement it for each outbound edge. We start with
a value of 1 since we arrived on an inbound edge.
Now, as soon as this counter is exactly zero, we know that on each side there
must be a matching number of inbound and outbound edges, so this will be
our terminal condition.

        for dir in [1,-1] # look in both directions
          #console.log "looking in direction", dir
          cursor = start.rotate(dir)
          counter = 1
          while start.position() isnt cursor.position()
            candidate = cursor()
            #if candidate is already connected, skip over to the connected
            #edge
            if candidate.connected?
              cursor.set candidate.connected

            else #if candidate.peer isnt start().peer
              # FIXME: this is a bit tricky. Edges may be redundant. We do not
              # want to count them more than once.
              #console.log "candidate", candidate
              #console.log "looking at", goto(cursor().occurrance)(1), cursor().direction
              counter = counter + (if candidate.direction == "inbound" then 1 else -1)
              if counter is 0 # and cursor().direction == "outbound"
                # do not forget to record the matches
                #console.log "match!"
                candidate.connected = start.position()
                start().connected = cursor.position()
                return candidate.occurrance
            cursor = cursor.rotate(dir)
        console.log "no continuation found. this is bad :-("
        console.log "arriving at vertex #{vId} via #{start().peer} on ring #{ringIndex}"
        console.log "adjacent Edges", adjacentEdges.data

Why does this work? Let's say `a` is the inbound arc we are comming from. `B`
are the arcs on the left (clockwise) up to but not including the next arc that
has already been connected. `C` are those on the right. The arcs in `B` and `C`
have not been used yet. Assuming that the algorithm worked correctly so far, we
know that if we look at all the arcs in `$B\cup {a} \cup C$` there must be as
many inbound arcs as there are outbound arcs.

So, we now can produce an array of rings without intersections

      outputRings = run()
      #console.log "outputRings", outputRings

## Orientation and containment

There is one issue left, that we need to solve. The output should include

- the orientation of each ring (clockwise/counter-clockwise)

- a containment relation.

### The orientation:

For each ring, we find a vertex of which we *know* that it is convex.
Since we know it has to be convex, we can determine the orientation of
the ring.
We can do this by calculating the (oriented) area of each ring.
There may be smarter ways to do this, but in our application we need the area
anyway, so we do accept the overhead.

### The containment:

If the orientation of the rings is known, we can compare touching rings
by looking at the joint at which they touch. We can see if one ring lies
inside of the other or not. This works as follows:
Each edge of the larger ring splits the plane into inside and outside.
If the larger ring contains the smaller ring, than for each edge of the larger ring
each vertex of the smaller ring must lie on the inside of that edge.
But here, in our special case, we do not have to check all edge - vertex pairs.
Since we know that rings cannot intersect, we only need to check the two adjacent
edges in the larger ring and one of adjacent vertices in the smaller ring.

For rings that do not share a vertex (do not touch), we use a more expansive
standard point-in-polygon check. Note that this *will not work correctly* for rings that
touch, so if we detected a shared vertex but no containment in the first
check, we absolutly *must* skip the second check.

      # sort by area in descending order
      # Remember the original position (for debugging only)
      r.i=i for r,i in outputRings
      outputRings.sort (a,b)->Math.abs(b.area()) - Math.abs(a.area())
      r.j=j for r,j in outputRings

      #console.log "outputRings", outputRings.map (r)->r.coords()

      parent = (smallerRing, i)->
        #console.log "smallerRing",i

        return if i is 0
        for j in [i-1 .. 0] when j >= 0
          touching = false
          #console.log "largerRing", j
          largerRing =outputRings[j]

          for vId, posInLarger of largerRing.jointPositions
            prevLarger = largerRing(posInLarger - 1)
            nextLarger = largerRing(posInLarger + 1)
            posInSmaller = smallerRing.jointPositions[vId]
            if posInSmaller?
              #console.log "rings #{i} and #{j} both contain #{vId} #{vertices[vId]}"
              touching = true
              nextSmaller = smallerRing(posInSmaller + 1)
              # ccw > 0 means "inside" if area > 0
              # ccw < 0 means "inside" if area < 0
              # thus: ccw * area > = means "inside"
              ccw1 = ccw vertices[prevLarger], vertices[vId], vertices[nextSmaller]
              ccw2 = ccw vertices[vId], vertices[nextLarger], vertices[nextSmaller]
              area = largerRing.area()

              if(ccw1*area > 0 and ccw2 * area > 0)
                #console.log "yep."

                #remember that we are touching our parent.
                smallerRing.touching=true
                return j
              #else
                #console.log "nope"

          # otherwise, use a more expensive check
          # IMPORTANT: only use this check, for rings that are *NOT* touching
          if not touching
            #console.log "expensive check: is #{i} is contained in #{j}?"
            if largerRing.contains smallerRing.coords()[0]
              #console.log "yep."
              return j
            #else
              #console.log "nope"

      for r,i in outputRings
        r.parent = parent r,i


## TODO: redundant arcs

I wrote modules for detecting and resolving redundant edges.
See modules `redundance` and `conditioner`.
The conditioner produces a table of rings and edges that need to be ignored
within these rings. Note that a redundant edge is per definition
an arc (of length 1). We need to make sure that these arcs are never traversed
when generating the output rings.
The conditioner also tells us which rings need to be flipped in order to preserve the overall
connectivity in the graph. This needs to be done on the *input* rings.

## Create Feature Collection

Finally, we want to output a GeoJSON `FeatureCollection` with features of type
`Polygon`. For this, determine the "root" of each output ring by traversing the `parent`
property.

      for outputRing,i in outputRings
        r = outputRing
        outputRing.root = i
        while r.parent?
          outputRing.root = r.parent
          r = outputRings[r.parent]


Next we group the rings by their respective root ring id. Note that the rings in each
group are still ordered by |area| (descending). So we can leave the loop early
once the area falls under a configured minimum

      groups = {}
      visibleRings = []
      for outputRing, i in outputRings
        if options.minArea? and Math.abs(outputRing.area()) < options.minArea
          #console.log "small ring", i
          break
        #console.log i, outputRing.parent
        if outputRing.parent?
          #console.log "check"
          parentRing = outputRings[outputRing.parent]
          if parentRing.redundant or outputRing.area() * parentRing.area() > 0
            outputRing.redundant = true
            #console.log "redundant ring", i
            continue if options.removeRedundantRings
        group = groups[outputRing.root] ?= []
        group.push outputRing
        visibleRings.push outputRing


Finally, we convert to GeoJSON, and we are done.


      if options.debug
        writeFileSync "/tmp/debug-#{options.debug}.svg", visualize {vertices,rings:visibleRings}

      switch (options.outputFormat ? "FeatureCollection")
        when "FeatureCollection"
          type: "FeatureCollection"
          features: (for _,group of groups
            type: "Feature"
            geometry:
              type: "Polygon"
              coordinates: group.map (outputRing)->
                closeRing outputRing.coords()
          )
        when "MultiPolygon"
          type: "Feature"
          geometry:
            type: "MultiPolygon"
            coordinates: (for _, group of groups
              group.map (outputRing)->closeRing outputRing.coords()
            )
        else
          for _, group of groups
            group.map (outputRing)->closeRing outputRing.coords()



