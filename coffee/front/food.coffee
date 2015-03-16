class Food extends GameObject
  color: 'green'

  constructor: (@game) ->
    @points = []
    do @respawn
    return

  respawn: ->
    free = @game.map.free
    if free.length > 0
      @set @game.map.free[random_int 0, free.length-1]
      do @unset if @points.length > 1
    else
      @game.started = no
      @game.over = yes
      @game.win = yes
      @game.msg_bottom.show 'WOOOOOW!!!<br> Snake has max size'
    return
