module.exports = ({scale=1, translate=[0,0]}={})->
  invert: ([x,y])->[(x-translate[0])/scale, (y-translate[1])/scale]
  scale:scale
  translate:translate
  transform:"translate("+translate+") scale("+scale+")"

