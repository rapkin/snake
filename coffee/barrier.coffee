class Barrier extends GameObject
  color: '#666'

  constructor: (@game, @points = []) ->
    do @border
    do @draw

  border: ->
    for i in [0...@game.width]
      @points.push [i, 0]
      @points.push [i, @game.height-1]
    for k in [1...@game.height-1]
      @points.push [0, k]
      @points.push [@game.width-1, k]
