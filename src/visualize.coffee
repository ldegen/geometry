fit = require "./fit"
{vScale} = require "./common"

strip2path = ([[x0,y0],rest...]) ->
  "M #{x0} #{y0} "+ rest.map(([x, y])->x+" "+y).join("L")

ring2path = (coords)->strip2path(coords)+"Z"
module.exports = ({vertices, rings, redundanceInfo=[], width=210, height=297})->

  #rings.sort (a,b)->a.i-b.i
  #console.log "rings", rings.map (r)->r.data

  reducer = ({left,right,bottom,top}, [x,y])->
    left: Math.min(left ? x, x)
    right: Math.max(right ? x, x)
    top: Math.min(top ? y, y)
    bottom: Math.max(top ? y, y)
  bbox = vertices.reduce reducer, {}

  viewport = top:0,left:0,bottom:height,right:width

  #console.log "bbox",bbox
  #console.log "viewport",viewport
  fitToView = fit bbox, viewport
  #console.log "fitToView", fitToView
  
  scale = vScale fitToView.scale

  edgeKey = (a,b)->
    if a<=b then [a,b] else [b,a]

  redundantStrips = (vIds, skip={})->
    #console.log "skip", skip
    strip = undefined
    strips = []
    for vId,pos in vIds
      prev = if pos is 0 then vIds.length - 1 else pos - 1
      key = edgeKey(vId,prev)
      if skip[key]
        if not strip?
          strip = [prev]
          strips.push strip
        strip.push vId
      else
        strip = undefined
    #console.log "strips", strips
    strips


  toCoords = (vId)->scale vertices[vId]

  ringGroup = (ring,ringId)->
    coords = ring.data
      .map toCoords

    outline = ring2path coords

    redundantPaths =redundantStrips(ring.data, redundanceInfo[ringId]?.skip )
      .map (strip)-> strip2path strip.map toCoords
      .map (d)->"""
                <path d="#{d}" class="redundant-edges" />
                """

    """
    <g class="ring #{if ring.area?()<0 then "cw" else "ccw"} child-of-#{ring.parent} area-#{ring.area?()}" id="ring-#{ringId}">
      <path d="#{outline}" class="background" />
      #{redundantPaths.join "\n"}
    </g>
    """

  ringGroups = rings.map ringGroup
  
  vertexLabels = vertices
    .map (coords, vId)->
      [x,y] = scale coords
      """
      <text x="#{x}" y="#{y}" font-size="0.5">#{vId}</text>
      """

  """
  <?xml version="1.0" standalone="no"?>
  <svg xmlns="http://www.w3.org/2000/svg" width="#{width}mm" height="#{height}mm" viewBox="0 0 #{width} #{height}">
    <defs>
      <style type="text/css">
        <![CDATA[
          .ring {
            fill: #dfac20;
            fill-opacity: 0.1;
            stroke-opacity: 0.1;
            stroke: #3983ab;
            stroke-width: 0.2;
         }
         .ring .redundant-edges {
            fill: none;
            stroke: red;
         }
        ]]>
      </style>
    </defs>
   
    <g transform="translate(#{fitToView.translate})">
      #{ringGroups.join("\n")}
      #{vertexLabels.join "\n"}
    </g>
  </svg>

  """

