C =
  vScale: (s)->([x,y])->[s*x,s*y]
  vAdd: ([b1,b2])->([a1,a2])->[a1+b1,a2+b2]
  vSubst:(b)->C.vAdd C.vScale(-1)(b)
  vSP: ([b1,b2])->([a1,a2])->a1*b1+a2*b2
  EPS: 1e-12
  vAlmostZero: (v)->C.vSP(v)(v) < C.EPS
  almostZero: (s)->(s*s) < C.EPS

module.exports=C
