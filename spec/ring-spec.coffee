describe "Navigation in a Ring", ->
  Ring = require "../src/ring"
  ring = undefined
  beforeEach ->
    ring = Ring [0,2,4,6,8]
  it "initially uses position 0 as reference", ->
    expect(ring()).to.eql 0
    expect(ring.position()).to.eql 0
  it "can address elements relative to the current position, wrapping at the edges", ->
    expect(ring(0)).to.eql 0
    expect(ring(1)).to.eql 2
    expect(ring(-1)).to.eql 8
    expect(ring(6)).to.eql 2
    expect(ring(-5)).to.eql 0
    expect(ring(-7)).to.eql 6

  it "can change the reference position relatively", ->
    ring = ring.rotate(8)
    expect(ring()).to.eql 6
    expect(ring.position()).to.eql 3

  it "can set an absolute reference position", ->
    ring = ring.rotate(3).set(3)
    expect(ring()).to.eql 6
    expect(ring.position()).to.eql 3

  it "can search forwards", ->
    ring = ring.rotate(2).search (v)->v==2
    expect(ring.position()).to.eql 1
    expect(ring.search ->false).to.be.undefined

  it "can search backwards", ->
    ring = ring.searchBackwards (v)->v==2
    expect(ring.position()).to.eql 1
    expect(ring.searchBackwards ->false).to.be.undefined
