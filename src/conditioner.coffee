
score = (input)->
  sum = 0
  max = 0

  for _, {ascending,descending} of input
    diff =Math.abs(ascending.length-descending.length)
    sum = sum + diff
    max = Math.max(max,diff)

  {sum, max}

removeElement = (arr, elm)->
  pos = arr.indexOf elm
  if pos is -1 then arr else [arr[0...pos]..., arr[pos+1...]...]
flip = ({cfg, flip}, ringId)->
  output = {}
  for edgeKey, {ascending,descending} of cfg

    ascending_ = removeElement ascending, ringId
    descending_ = removeElement descending, ringId
    
    output[edgeKey]=
      ascending: if descending_.length < descending.length then [ascending_...,ringId] else ascending_
      descending: if ascending_.length < ascending.length then [descending_...,ringId] else descending_
  
  flip: [flip...,ringId]
  cfg: output
  score: score output

acceptable = ({score})->score.max < 2

module.exports = (input)->

  # notes
  #
  # we never should have to flip the same ring twice.
  # You can imagine the possible configurations as the corners of a hypercube.
  # The edges can be traversed by flipping one ring.
  # If one corner is an acceptable solution, so is the opposite corner.
  #
  # The score we assign to any configuration has a maximum and a sum component.
  # See function above for details.
  # A configuration is acceptable if its maximum score is less than 2.
  # The sum component is used as a heuristic on local choices. (next ring to flip)
  # The smaller, the better.
  #
  # We are looking for an acceptable solution that can be reached with a minimal
  # number of flips.
  
  corner =
    flip: []
    cfg: input
    score: score input
  
  ringIds = do ->
    ids = {}
    for _, {ascending,descending} of input
      ids[id]=id for id in ascending
      ids[id]=id for id in descending

    Object.keys(ids).map((id)->ids[id]).sort()

  while not acceptable corner
    choices = (flip corner, ringId for ringId in ringIds when corner.flip.indexOf(ringId) is -1)
    if choices.length is 0
      throw new Error("no choices left")
    corner = choices.sort(({score:sum:a},{score:sum:b})-> a-b)[0]

  output = {}

  for ringId in corner.flip
    entry = output[ringId] ?= {flip:true, skip:{}}
  for edgeId, {ascending,descending} of corner.cfg
    len = Math.min ascending.length, descending.length
    affectedRingIds = ascending.slice(0,len).concat(descending.slice(0,len))
    for ringId in affectedRingIds
      entry = output[ringId] ?= {flip:false, skip:{}}
      entry.skip[edgeId] = true
     
  output


