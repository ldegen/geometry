# The cut - Tool

This creates a function that cuts a simple polygon ring along
an infinite line through `s1` and `s2`.

The ring does not need to be convex, but it must be simple, i.e.
not contain self-intersections or zero-length edges.

    module.exports = ([s1,s2])->(ring)->

Most of our lower-level utility functions are already defined

      {coefficients, vInterpolate, vProject, vSubst, vAlmostZero, almostZero
       coefficient, ringEdges, ringArea} = require './common'
      ccw = require './ccw'
      group = require './group'
      flatMap = (arr, transform) -> [].concat((arr.map(transform))...)
      mu = coefficient([s1,s2])
      interpolate = vInterpolate(s1,s2)

We calculate the oriented area of the ring.
A positive sign means vertices are labled in counter-clock-wise order
(assuming positive y points "up")
We need this info later.

      area = ringArea ring
      ringIsCCW = (area > 0)

The algorithem comprises two phases:

- in the first phase, the input ring is
  cut down into fragments such that each fragment completly lies on either the
  left or the right side of the cutting line

- in the second phase, the fragments are connected to rings.

## Phase I: cutting the ring into fragments

We start by transforming our ring into a list of edges that are either on the left or the right side
of the cutting line.

      edges = flatMap ringEdges(ring), ([a,b])->
        sideA = - ccw s1, s2, a, true
        sideB = - ccw s1, s2, b, true

We have to handle four (five, actually) different cases:
- when the edge intersects the cutting line we output *two* edges, one on each side.
- when the edge is a subset of the cutting line, we can still associate it with one side:
  If it is in the same direction as the cutting line, and the vertices are labeld counter-clock-wise,
  then we associate it with the left side since the inside of the ring is left. Otherwise we label it right.
- If one of the two edges is on the cutting line, we need to calculate the associated coefficient
  so we can later connect the fragments correctly. (see below)
- the remaining two cases are edges that are entirely on one side.

        switch
          when sideA * sideB < 0
            [lambda] = coefficients [s1,s2],[a,b]
            x = interpolate lambda
            [
              start:a
              end: x
              endAt: lambda
              side: Math.sign sideA
            ,
              start: x
              end: b
              startAt: lambda
              side: Math.sign sideB
            ]
          when sideA is 0 and sideB is 0 # edge is subset of cutting line
            lambdaA = mu a
            lambdaB = mu b
            [
              start: a
              startAt: lambdaA
              end: b
              endAt: lambdaB
              side: if ringIsCCW and lambdaA < lambdaB then -1 else 1
            ]
          when sideA is 0
            [
              start: a
              startAt: mu a
              end: b
              side: Math.sign sideB
            ]
          when sideB is 0
            [
              start: a
              end: b
              endAt: mu b
              side: Math.sign sideA
            ]
          else # same side, none zero
            [
              start: a
              end: b
              side: Math.sign sideA #or sideB, doesn't matter.
            ]

Next we collect consecutive edges that are on the same side into groups. We then transform the
edge groups into fragments.

      fragments = group edges, (edge)->edge.side
        .map ({value, elements})->
          [firstEdge,..., lastEdge] = elements
          firstVertex = firstEdge.start
          otherVertices = elements.map (edge)->edge.end

          startAt: firstEdge.startAt # maybe undefined for the very first fragment
          endAt: lastEdge.endAt # maybe undefined for the very last fragment
          vertices: [firstVertex, otherVertices...]
          side: value

## Phase II: Connecting the fragments

All but the first fragment start at the cutting line.
All but the last fragment end at the cutting line.
(Actually, also the first and the last fragment may start/end at the cutting line, but we don't care.)
These points, where fragments touch the cutting line each have an associated coefficient (I tend to call "lambda").
These lambdas are stored in the `startAt`, `endAt` properties of the fragments and describe the position said start or end
point with respect to the cutting line, i.e. `x = s1 + lambda * (s2 - s1)`.

Let's extract these lambdas and sort them along the cutting line.

      lambdas = flatMap fragments, ({startAt,endAt})->[startAt, endAt]
        .sort()
        .filter (lambda,i,arr)-> lambda? and lambda isnt arr[i-1]


Now that our lambdas are nicely aligned, we observe that when connecting the fragments back together, we always have to connect endpoints
that are lying next to each other on the cutting line. Assuming counter-clock-wise labeling, when we are looking at a fragment on the left
side that ends at `lambda_i`, we need to find the fragment that starts at `lambda_(i+1)` and connect it. For fragments on the right side,
it would be `lambda_(i-1)` instead. If vertices are labeled clock-wise, it's the other way arround.
So let's build a lookup table where we can lookup fragments by their `startAt` property

      fragmentsStartingAt = {}
      fragmentsStartingAt[fragment.startAt] = fragment for fragment in fragments when fragment.startAt?

Next, we create a data structure that will lookup the "peer" of each intersection lambda.

      peerLambdas = {}
      for i in [0...Math.floor(lambdas.length/2)]
        a = lambdas[2*i]
        b = lambdas[2*i+1]
        peerLambdas[a] = b
        peerLambdas[b] = a

We combin both lookups to create a function that can look at the `endAt`-Property of one
fragment and find another fragment to continue the ring with.

      findContinuation = (fragment)-> fragmentsStartingAt[peerLambdas[fragment.endAt]]

Now everything is prepared for connecting the fragments to rings. We take one fragment from our list and try to connect
other fragments to using our lookup table and the rule defined above. All connected fragments are marked "done"; we do not
want to start a ring on a fragment that is already contained in a ring. When we cannot conect any more fragments, we
start the next ring with the next unmarked fragment. We cary on until all fragments are marked done.

      leftRings = []
      rightRings = []

      for startFragment in fragments when not startFragment.done
        ring = startFragment.vertices.slice()
        side = startFragment.side
        fragment = findContinuation startFragment
        while fragment? and fragment isnt startFragment
          ring.push fragment.vertices...
          fragment.done = true
          fragment = findContinuation fragment

        # if the ring did not start at a pseudo vertex,
        # the first and the last vertex will be identical.
        # Fix it.
        ring.pop() if ring[0] is ring[ring.length-1]

        switch
          when side < 0
            leftRings.push ring
          when side > 0
            rightRings.push ring
          else
            throw new Error("Srsly, wtf?!")

      [leftRings, rightRings]

