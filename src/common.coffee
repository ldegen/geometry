




C =
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
