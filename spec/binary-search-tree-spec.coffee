describe "The Binary Search Tree", ->
  BinarySearchTree = require "../src/binary-search-tree"
  shortNode = (key)->(left=null,right=null)->[key,left,right]
  [m,ä,á,é,r,t,o,n] = (shortNode c for c in "mäáérton")
  _t = (k,v,l,r)->
    key:k
    value:v
    left:l
    right:r

  trace = undefined
  beforeEach ->
    trace = []
  cmp = (a,b)->
    switch
      when a is 'á' and b is 'é' or a is 'é' and b is 'á'
        trace.push "#{a}!#{b}"
        return undefined
      when a<b
        trace.push "#{a}<#{b}"
        return -1
      when a>b
        trace.push "#{a}>#{b}"
        return 1
      else
        trace.push "#{a}=#{b}"
        return 0
  it "is initially empty", ->
    tree = BinarySearchTree cmp
    expect(tree.empty()).to.be.truthy

  it "dynamically builds a tree", ->
    tree = BinarySearchTree cmp
    tree.insert c,c for c in "márton"
    expect(trace).to.eql [
      "á>m"
      "r>m", "r<á"
      "t>m", "t<á", "t>r"
      "o>m", "o<á", "o<r"
      "n>m", "n<á", "n<r", "n<o"
    ]
    expect(tree.dumpKeys()).to.eql(
      m(
        null,
        á(
          r(
            o(n()),
            t()
          )
        )
      )
    )
  describe "get", ->
    tree = undefined
    beforeEach ->
      tree = BinarySearchTree cmp
      tree.insert c,i for c, i in "márton"
      trace = []
    it "returns the value for a key", ->
      v = tree.get 'r'
      expect(v).to.equal 2
      expect(trace).to.eql ["r>m","r<á","r=r"]

    it "returns undefined if no node with that key is found", ->
      v = tree.get 'v'
      expect(v).to.be.undefined
      expect(trace).to.eql ["v>m", "v<á", "v>r", "v>t"]
 
  describe "in-order traversal", ->
    tree = undefined
    beforeEach ->
      tree = BinarySearchTree cmp
      tree.insert c,i for c, i in "márton"
      trace = []
    it "can traverse the tree inorder", ->
      node = tree.first()
      buf = ""
      while node?.key?
        buf+=node.key
        node = node.next()
      expect(buf).to.eql "mnortá"

    it "can traverse the tree in reverse order", ->
      node = tree.last()
      buf = ""
      while node?.key?
        buf=node.key+buf
        node = node.prev()
      expect(buf).to.eql "mnortá"

  describe "remove", ->
    tree = undefined
    beforeEach ->
      tree = BinarySearchTree cmp, -> 0.1
      tree.insert c,i for c, i in "márton"
      trace = []

    it "removes leafs without otherwise changing the structure", ->
      tree.remove "t"

      expect(tree.dumpKeys()).to.eql(
        m(
          null,
          á(
            r(o(n()))
          )
        )
      )

    it "inlines nodes with only a right child", ->
      tree.remove 'm'

      expect(tree.dumpKeys()).to.eql(
        á(
          r(
            o(n()),
            t()
          )
        )
      )

    it "inlines nodes with only a left child", ->
      tree.remove 'á'
      
      expect(tree.dumpKeys()).to.eql(
        m(
          null,
          r(
            o(n()),
            t()
          )
        )
      )

    it "replaces nodes with both children with its inorader neighbour", ->
      tree.remove 'r'

      expect(tree.dumpKeys()).to.eql(
        m(
          null,
          á(
            o(
              n(),
              t()
            )
          )
        )
      )

  describe "when inserting a key that conflicts with an existing key", ->
    tree = undefined
    beforeEach ->
      tree = BinarySearchTree cmp, -> 0.1
      tree.insert c,i for c, i in "márton"
      trace = []
    it "removes the existing node and reports the conflicting keys", ->
      conflicts = []
      tree.insert 'é',42, (a,b)->conflicts.push "#{a.key}!#{b.key}"
      expect(trace).to.eql [
        'é>m'
        'é!á'
      ]
      expect(tree.dumpKeys()).to.eql(
        m(null,r(o(n()),t()))
      )
      expect(conflicts).to.eql ["é!á"]

  describe "when encountering conflicts during removal", ->

    tree = undefined
    beforeEach ->
      tree = BinarySearchTree cmp, -> 0.1
      
      tree.insert c,i for c, i in "mäáérton"
      trace = []
      expect(tree.dumpKeys()).to.eql(
        m(
          null,
          ä(
            á(
              r(
                o(n()),
                t()
              )
            ),
            é()
          )
        )
      )

    it "removes and reports the conflicting keys", ->
      conflicts = []
      tree.remove 'ä', (a,b)->conflicts.push "#{a.key}!#{b.key}"
      expect(conflicts).to.eql ["á!é"]
      expect(tree.dumpKeys()).to.eql(
        m(
          null,
          t(
            r(
              o(n())
            )
          )
        )
      )
