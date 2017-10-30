describe "The edge conditioner", ->
  conditioner = require "../src/conditioner"
  it "determines which rings should be flipped and which edges are redundant", ->
    
    input =
      '1,8': ascending:[0,2], descending:[]
      '5,8': ascending:[1], descending:[0,2]
      '4,5': ascending:[1], descending:[2]

    expect(conditioner input).to.eql
      0:
        flip: true
        skip: '1,8':true
      1:
        flip: false
        skip:
          '5,8':true
          '4,5':true
      2:
        flip: false
        skip:
          '1,8': true
          '5,8': true
          '4,5': true


