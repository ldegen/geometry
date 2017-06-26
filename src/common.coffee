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
    a = @direction(@vSubst(s1)(s2))
    t = @composeTf @translate(s1), @rotate(a)
    tInv = @composeTf @rotate(-a), @translate(@vNegate(s1))
    @composeTf t, @scale(-1,1), tInv

  composeTf: (matrices...)-> matrices.reduce aTfProd

  applyTf: ([a,b,c,d,e,f])->([x,y])->[
    a*x + c*y + e
    b*x + d*y + f
  ]

  applyTfs: (tfs...)->
    @applyTf @composeTf tfs...
    

  # assuming negativ y pointin g up, this
  # returns the angle in radians to the y axis.
  # Positive angles are clock-wise.
  direction: ([x,y])->atan2(x,-y)
    

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
  almostZero: (s)->(s*s) < C.EPS

module.exports=C
