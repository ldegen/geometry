describe "The Binary Search Tree", ->
  BinarySearchTree = require "../src/binary-search-tree"
  t = (k,v,l,r)->
    key:k
    value:v
    left:l
    right:r

  trace = undefined
  beforeEach ->
    trace = []
  cmp = (a,b)->
    switch
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
    tree.insert n,n for n in "márton"
    expect(trace).to.eql [
      "á>m"
      "r>m", "r<á"
      "t>m", "t<á", "t>r"
      "o>m", "o<á", "o<r"
      "n>m", "n<á", "n<r", "n<o"
    ]
    expect(tree.dump()).to.eql(
      t("m","m",
        null,
        t("á","á",
          t("r","r",
            t('o',"o",
              t('n',"n", null, null),
              null
            ),
            t('t', "t", null, null)
          ),
          null
        )
      )
    )
  describe "get", ->
    tree = undefined
    beforeEach ->
      tree = BinarySearchTree cmp
      tree.insert n,i for n, i in "márton"
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
      tree.insert n,i for n, i in "márton"
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
      tree.insert n,i for n, i in "márton"
      trace = []

    it "removes leafs without otherwise changing the structure", ->
      tree.remove "t"

      expect(tree.dump()).to.eql(
        t("m",0,
          null,
          t("á",1,
            t("r",2,
              t('o',4,
                t('n',5, null, null),
                null
              ),
              null
            ),
            null
          )
        )
      )

    it "inlines nodes with only a right child", ->
      tree.remove 'm'

      expect(tree.dump()).to.eql(
        t("á",1,
          t("r",2,
            t('o',4,
              t('n',5, null, null),
              null
            ),
            t('t', 3, null, null)
          ),
          null
        )
      )

    it "inlines nodes with only a left child", ->
      tree.remove 'á'
      
      expect(tree.dump()).to.eql(
        t("m",0,
          null,
          t("r",2,
            t('o',4,
              t('n',5, null, null),
              null
            ),
            t('t', 3, null, null)
          ),
          null
        )
      )

    it "replaces nodes with both children with its inorader neighbour", ->
      tree.remove 'r'

      expect(tree.dump()).to.eql(
        t("m",0,
          null,
          t("á",1,
            t("o",4,
              t('n',5, null, null),
              t('t', 3, null, null)
            ),
            null
          )
        )
      )

