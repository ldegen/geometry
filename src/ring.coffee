ring = (elements, position0=0)->
  N = elements.length
  normalize = (i)-> if i%N < 0 then N + i % N else i % N
  position = normalize(position0)
  get = (i=0)-> elements[normalize(i+position)]
  get.get = get
  get.set = (i)->ring(elements,i)
  get.rotate = (i)->get.set(position+i)
  get.position = ->position
  get.data = elements
  get.search = (pred)->
    for i in [0...N]
      return get.rotate(i) if pred(get(i),i,normalize(position+i))
  get.searchBackwards = (pred)->
    for i in [0...-N]
      return get.rotate(i) if pred(get(i),i,normalize(position+i))

  get

module.exports = ring


