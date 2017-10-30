module.exports = (edges)->
  # count edge redundancies
  edgeKey = (a,b) ->
    if a<b then key:[a,b], direction:"ascending" else key:[b,a], direction:"descending"
  edgeUsage = {}
  for strip, stripId in edges
    for b,i in strip
      a = if i is 0 then strip[strip.length - 1] else strip[i - 1]
      {key,direction} = edgeKey(a,b)
      usage = edgeUsage[key] ?= ascending:[], descending:[]
      usage[direction].push stripId

  for key,usage of edgeUsage when usage.ascending.length + usage.descending.length < 2
    delete edgeUsage[key]

  edgeUsage
