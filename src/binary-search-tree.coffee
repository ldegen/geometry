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
  isEmpty: -> not @key?
  goto:(key)->
    return this if not @key
    c = @cmp key, @key
    n = switch
      when c<0 then (@left ?= new TreeNode @cmp,this, LEFT).goto key
      when c>0 then (@right ?= new TreeNode @cmp, this, RIGHT).goto key
      else this # TODO: allow multiple nodes with the same key?
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
  remove: (rnd)->
    return if not @key?
    switch
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
        other = if rnd() <0.5 then @prev() else @next()
        @key = other.key
        @value = other.value
        other.remove rnd


  dump: ->
    if not @key? then null else
      key:@key
      value:@value
      left: @left?.dump() ? null
      right: @right?.dump() ? null



module.exports = (cmp=defaultCmp,rnd=Math.random)->
  root = new TreeNode cmp

  empty: -> root.isEmpty()
  insert: (key, value=key)->
    node = root.goto key
    node.key=key
    node.value=value
  remove: (key)->
    node = root.goto key
    node.remove rnd

  first: ->root.min()
  last: ->root.max()

  get: (key)->
    node = root.goto key
    node.value unless node.isEmpty()
  dump: -> root.dump()
