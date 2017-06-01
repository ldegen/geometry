describe "The trees-Function", ->
  trees = require '../src/trees'
  it "connects edges to trees", ->
    edges =[
      [0, 1, 2]
      [1,3, 4]
      [3,5]
      [6,7,8]
      [6,9]
    ]
    expect(trees(edges)).to.eql [
      [0,
        [1,
          [2]
          [3,
            [4]
            [5]
          ]
        ]
      ]
      [6,
        [7,
          [8]
        ]
        [9]
      ]
    ]

