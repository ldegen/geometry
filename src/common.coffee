{sin,cos,atan2, PI} = Math

# simple matrix product, but for the special in which both
# operands are affine linear transformations
#
#   a c e
#   b d f
#   0 0 1
#
# which are stored as [a,b,c,d,e,f]
aTfProd = ([a0,a1,a2,a3,a4,a5],[b0,b1,b2,b3,b4,b5])->[
  a0*b0 + a2*b1,      a1*b0 + a3*b1
  a0*b2 + a2*b3,      a1*b2 + a3*b3
  a0*b4 + a2*b5 + a4, a1*b4 + a3*b5 + a5
]

# apply an affine linear transformation (see above) to an vector [x1,x2]
#
# i.e. returns an array [y1, y2] such that
#
#   / y1 \    / a c e \  / x1 \
#   | y2 | =  | b d f |  | x2 |
#   \ 1  /    \ 0 0 1 /  \ 1  /
#

applyTf =([x1,x2], [a,b,c,d,e,f])->[
    a*x1 + c*x2 + e
    b*x1 + d*x2 + f
  ]

C =
  
  deg: (a)-> 180 * a / PI

  rad: (a)-> PI * a / 180

  rotate: (a)-> [
    cos(a),   sin(a)
    -sin(a),   cos(a)
    0, 0
  ]

  scale: (sx,sy)->[
    sx, 0
    0, sy
    0, 0
  ]
    
  translate: (tx0,ty0)->
    [tx,ty] = if not ty0? then tx0 else [tx0,ty0]
  
    [
      1, 0
      0, 1
      tx, ty
    ]

  vNegate: ([x,y])->[-x,-y]
  mirror: (s1,s2)->
    a = C.direction(C.vSubst(s1)(s2))
    t = C.composeTf C.translate(s1), C.rotate(a)
    tInv = C.composeTf C.rotate(-a), C.translate(C.vNegate(s1))
    C.composeTf t, C.scale(-1,1), tInv

  composeTf: (matrices...)-> matrices.reduce aTfProd

  applyTf: ([a,b,c,d,e,f])->([x,y])->[
    a*x + c*y + e
    b*x + d*y + f
  ]

  applyTfs: (tfs...)->
    C.applyTf C.composeTf tfs...
    

  # assuming negativ y pointin g up, this
  # returns the angle in radians to the y axis.
  # Positive angles are clock-wise.
  direction: ([x,y])->atan2(x,-y)
    
  coefficient: ([s1,s2])->
    [dx,dy] = d = C.vSubst(s1)(s2)
    i = if dx*dx > dy*dy then 0 else 1
    (x)->
      v = C.vSubst(s1)(x)
      v[i] / d[i]

  coefficients: (args...)->
    #console.log "args", args...
    [[s1,s2],[t1,t2]]=args
    b = C.vSubst(t1)(s1)
    #console.log "b",b
    # the columns of A:
    a1 = C.vSubst(s2)(s1)
    a2 = C.vSubst(t1)(t2)
    #console.log "a^1",a1
    #console.log "a^2",a2

    # solve Ax=b á la Cramer:
    d = C.det a1, a2
    return if C.almostZero d

    d1 = C.det b, a2
    d2 = C.det a1, b
    #console.log "d", d
    #console.log "d1", d1
    #console.log "d2", d2

    [d1/d, d2/d]


  vProject: (from, to)->
    # transform coordinates so from ends up in the origin
    t = C.vSubst from
    tInv =C.vAdd  from

    # the vector we project upon
    b = t to

    (point) ->
      a = t point
      tInv C.vScale(C.vSP(a)(b) / C.vSP(b)(b))(b)
    


  vInterpolate: (a,b) -> (λ) ->
    d = C.vSubst(a)(b)
    λd = C.vScale(λ)(d)
    #console.log "a", a
    #console.log "b", b
    #console.log "λ", λ
    #console.log "d", d
    #console.log "λd", λd
    C.vAdd(λd)(a)
  vScale: (s)->([x,y])->[s*x,s*y]
  vAdd: ([b1,b2])->([a1,a2])->[a1+b1,a2+b2]
  vSubst:(b)->C.vAdd C.vScale(-1)(b)
  vSP: ([b1,b2])->([a1,a2])->a1*b1+a2*b2
  det: ([a1,a2],[b1,b2])->a1*b2-a2*b1
  EPS: 1e-12
  vAlmostZero: (v)->C.vSP(v)(v) < C.EPS
  vAlmostSame: (a)->
    f = C.vSubst a
    (b)->C.vAlmostZero f b
  almostZero: (s)->(s*s) < C.EPS
  ringEdges: (points) ->
    points.map (v,i,vs)->
      if i is 0 then [vs[vs.length-1],v] else [vs[i-1],v]
  # note: positive area means counter-clock-wise orientation
  # (assuming positive y-axis points down)
  ringArea: (points)-> # google for "shoelace formular"
    0.5 * C.ringEdges(points)
      .map ([[x1,y1],[x2,y2]])->(x2-x1)*(y2+y1)
      .reduce (a,b)->a+b

  closeRing: (ring)->
    [first,...,last]= ring
    if C.vAlmostSame(last)(first) then ring else [ring...,first]

  openRing: (ring)->
    [first,...,last] = ring
    if C.vAlmostSame(last)(first) then ring.slice(0,-1) else ring

  makeRingCcw: (ring)->
    if C.ringArea(ring) > 0 then ring else ring.slice().reverse()

  makeRingCw: (ring)->
    if C.ringArea(ring) < 0 then ring else ring.slice().reverse()

  geoJson2rings: ({geometry:{coordinates}})-> coordinates.map C.openRing

  rings2geoJson: (rings0)->
    rings = rings0
      .map (ring,i)-> if i is 0 then C.makeRingCcw(ring) else C.makeRingCw(ring)
      .map C.closeRing
             
    type: "Feature"
    geometry:
      type: "Polygon"
      coordinates: rings


module.exports=C
