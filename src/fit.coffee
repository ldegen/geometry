transform = require('./transform')

module.exports = (ftr, vwp) ->
  dx = ftr.right - (ftr.left)
  dy = ftr.bottom - (ftr.top)
  x = (ftr.left + ftr.right) / 2
  y = (ftr.top + ftr.bottom) / 2
  dv = vwp.right - (vwp.left)
  dw = vwp.bottom - (vwp.top)
  v = (vwp.left + vwp.right) / 2
  w = (vwp.top + vwp.bottom) / 2
  scale = 1 / Math.max(dx / dv, dy / dw)
  translate = [
    v - (scale * x)
    w - (scale * y)
  ]
  transform
    scale: scale
    translate: translate
