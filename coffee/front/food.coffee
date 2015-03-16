class Food extends GameObject
  color: 'green'

  constructor: (@game) ->
    @points = []
    do @respawn

  respawn: ->
    free = @game.map.free
    if free.length > 0
      @set @game.map.free[random_int 0, free.length-1]
      do @unset if @points.length > 1
    else @game.win = yes
    return
