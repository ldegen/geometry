defaultCmp = (a,b)->
  switch
    when a < b then -1
    when b < a then 1
    else 0

LEFT=0
RIGHT=1
class TreeNode
  constructor:(@cmp, @up,@direction)->
    @key=null
    @value=null
    @depth = if @up? then @up.depth + 1 else 0
  isEmpty: -> not @key?
  goto:(key)->
    return this if not @key
    c = @cmp key, @key
    n = switch
      when c<0 then (@left ?= new TreeNode @cmp,this, LEFT).goto key
      when c>0 then (@right ?= new TreeNode @cmp, this, RIGHT).goto key
      when c==0 then this # TODO: allow multiple nodes with the same key?
      else
        # The two keys could not be compared.
        # In the context of our bentley-ottmann implementation
        # this means that the both nodes represent crossing line segements.
        # TODO: both segments need to be split at the intersection point.
        #   I do not want to do this here.
        #   We need some kind of callback mechanism to actually do this.
        @conflictingKey=key
        this
  min: ->
    if @left?.key? then @left.min() else this
  max: ->
    if @right?.key? then @right.max() else this
  rightAnchestor: ->
    switch @direction
      when LEFT then @up
      when RIGHT then @up.rightAnchestor()
  leftAnchestor: ->
    switch @direction
      when RIGHT then @up
      when LEFT then @up.leftAnchestor()
  next: ->
    if @right?.key? then @right.min() else @rightAnchestor()
  prev: ->
    if @left?.key? then @left.max() else @leftAnchestor()
  remove: (rnd, report)->
    return if not @key?
    switch
      # In all cases, the adjacence relation changes.
      # For our particular use case, we cannot assume that our
      # "generalized order relation" is transitive.
      # So we need to add an explicit comparison when two nodes
      # become adjacent that were not compared before.
      # This however can only be the case in the last case.
      #
      # note: when looking at an arbitrary node in the tree, we
      # know that during insertion it *has* been compared with
      # each of its ancestors.
      #
      # note: should we ever decide to do any kind of balancing
      # the beforementioned assumption needs to be reevaluated.
      when not @left? and not @right?
        @key=null
        @value=null
      when not @left?
        @key = @right.key
        @value = @right.value
        @left = @right.left
        @right = @right.right
      when not @right?
        @key = @left.key
        @value = @left.value
        @right = @left.right
        @left = @left.left
      else
        useLeft = rnd() < 0.5
        replacement=undefined
        newNeighbour=undefined
        check=undefined
        if useLeft
          replacement = @prev()
          newNeighbour = @right
          check = @cmp replacement.key, newNeighbour.key
        else
          replacement = @next()
          newNeighbour = @left
          check = @cmp newNeighbour.key, replacement.key

        console.log "removing", @key
        console.log "replacement", replacement.key
        console.log "newNeighbour", newNeighbour.key
        console.log "check", check
        if check < 0
          # replacement is consistent. Do it.
          @key = replacement.key
          @value = replacement.value
          replacement.remove rnd, report
        else
          # inconsistency found!
          # We remove *both* nodes, *and* this one
          a = replacement.key
          b = newNeighbour.key
          @key = replacement.key
          @value = replacement.value
          replacement.remove rnd, report
          @remove rnd, report
          newNeighbour.remove rnd, report
          report a, b


  dumpKeys: -> if not @key? then null else [
    @key
    @left?.dumpKeys() ? null
    @right?.dumpKeys() ? null
  ]


  dump: ->
    if not @key? then null else
      key:@key
      value:@value
      left: @left?.dump() ? null
      right: @right?.dump() ? null



module.exports = (cmp=defaultCmp,rnd=Math.random)->
  root = new TreeNode cmp

  empty: -> root.isEmpty()
  insert: (key, value=key, reportConflict)->
    node = root.goto key
    if node.conflictingKey?
      reportConflict node.conflictingKey, node.key
      node.remove rnd
    else
      node.key=key
      node.value=value
  remove: (key, reportConflict)->
    node = root.goto key
    node.remove rnd, reportConflict

  first: ->root.min()
  last: ->root.max()

  get: (key)->
    node = root.goto key
    node.value unless node.isEmpty()
  dump: -> root.dump()
  dumpKeys: ->root.dumpKeys()
