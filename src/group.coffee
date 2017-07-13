module.exports = (arr, crit)->
  reducer = (groups, elm)->
    c = crit elm
    prev =groups[groups.length - 1]
    if prev?.value is c
      prev.elements.push elm
    else
      groups.push
        value:c
        elements:[elm]
    groups

  arr.reduce reducer, []

