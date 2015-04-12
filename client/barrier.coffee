class Barrier extends GameObject
  color: '#333'

  constructor: (@game) ->
    @points = []
    points = window.barrier or []
    for p in points
      @set @get p[0], p[1]
