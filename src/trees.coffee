module.exports = (edges)->
  lookup = []
  output = []
  node =(v,p)->
    n = lookup[v]
    if not n?
      n = [v]
      lookup[v]=n
      if not p?
        output.push n
    if p?
      p.push n

    n


  for edge in edges
    n = null
    for vertice in edge
      n = node(vertice,n)


  output
