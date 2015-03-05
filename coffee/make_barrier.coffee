module.exports = (barrier) ->
  temp = []
  for line in barrier.lines
    if line.by is 'x'
      for x in [line.range[0]..line.range[1]]
        temp.push [x, line.y]
    if line.by is 'y'
      for y in [line.range[0]..line.range[1]]
        temp.push [line.x, y]

  for point in barrier.points
    temp.push point
  return JSON.stringify temp
