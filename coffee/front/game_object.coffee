class GameObject
  color: '#fff'

  get: (x, y) ->
    @game.map.get x, y

  set: (point) ->
    @points.unshift @game.map.set point, @

  unset: (point) ->
    @game.map.unset @points.pop()
