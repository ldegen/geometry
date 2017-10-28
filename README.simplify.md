## Goal

A polygon with holes is typically represented as a set of simple
non-intersecting polygonal rings, one being the outer boundary, the others
being holes. The boundary is usually expected to subsume the holes. Did I
mention that the rings should be simple?

The goal of this algorithm is to clean up any mess you through at it and make
it a set of polygons in the above sense. The input is required to be an array
of rings. A ring is required to be an array of coordinate pairs. This is
basically what the format of the `coordinates`-Property in a GeoJSON `geometry`
of type `"Polygon"`. However this algorithm does not care wether the first and
the last vertex of a ring are the same.

So the input may look like this: \[\[\[1,2\],\[2,3\],\[3,4\]\],
\[\[42,1\],\[0.4,2\], …\],… \]

The input is allowed to be quite a mess.

-   self intersections and cross intersections are ok

-   duplicate vertices are ok

-   an arbitrary number of edges intersecting in a single vertex *should* be ok

-   rings may be in any order. Don't worry about what is the contour outline,
    or which are the holes. It does not matter.

There are some things to consider, though

-   The winding direction of the input rings does affect the output. Example:

        +-----+
        |  A  |
        |     |
        | +---+----+
        | |   |    |
        | |   |   B|
        | +---+----+
        |     |
        +-----+

    Think of this as two overlapping rings. If they have the same winding direction,
    The result would be the to rings union(A,B) and intersection(A,B).
    If their winding direction differs, the resulting rings would be B\A and A\B.

    Of all variants I tried, this one seems to cause the least confusion.
    
-   one thing that will cause problems are duplicated edges. We assume that
    rings do not share edges. If they do, this needs probably be addressed in
    application-specific ways. For instance in my application the "touching"
    rings need to be merged (think "set union"), which effectively removes
    those edges. But I am not sure if this could be generalized.

The ouput will be in a format suitable for the `coordinates`-Property in a
GeoJSON `geometry` of type `"MultiPolygon"`. I.e. several of those things above
wrapped in another array.

The output has all the good stuff you are after:

-   zero intersections, neither self nor cross.

-   rings will not contain duplicate vertices except for the first and the last
    one (see above)

-   Each polygon is a list of rings, the first ring is always the outer
    boundary.

-   The outer boundary is always in ccw order, the holes are cw. Or vice versa,
    depending on the orientation of your coordinate system. Whatever it is, it
    will be consistent.

## Disclaimer

This is an experiment. I am still working on it.

Optimal performance is *not* my goal, but rather robustness. The dominating
factor here is determining intersections. I looked for an Bentley-Ottmann
implementation, there are a couple on npmjs.com but I did not like the ones I
looked at. I either didn't get them to work or they did not work like I wanted
them to. This is *not* because they are bad, but rather because I am lazy, as I
said: performance is no priority atm.

I settled with `geojson-polygon-self-intersections` for now, which uses a
spatial index rather than a sweep-line approach. Should not be a big issue to
replace it with something more sophisticated, though.

## Idea

I used `simplepolygon` which works well but does not cover some edge cases. In
particular it refuses to process anything with duplicate vertices. I was
looking for a way around this problem and my original intention was to "fix"
`simplepolygon`. It seems that the limitation stemms from the formulation of
the original algorithm, which is presented in [a thesis submitted by Lavanya
Subramaniam: Subramaniam, Lavanya. Partition of a Non-simple Polygon Into
Simple Polygons. Diss. University of South Alabama,
2003](http://www.cis.southalabama.edu/~hain/general/Theses/Subramaniam_thesis.pdf)

Read it. It is very well written and really helpful.

I try to summarize the idea: once you have detected all intersections, you can
represent your polygon(s) as a planar directed graph. We asume that rings don't
share edges. It is trivial to see that the graph is created from disjunct edge
cycles. The trick is to find a set of cycles that do not contain
"intersections". Which seems a bit contradicionary: We *know* that some of the
vertices represent intersections, how do we deal with them?

For every vertex in our graph the number of inbound edges is equal to the
number of outbound edges. A "normal" vertex has exactly one inbound and one
outbound edge. An "intersection" vertex however has more in- and outbound
edges.humhum
