class Food extends GameObject
  color: 'green'

  constructor: (@game) ->
    do @respawn
    return

  respawn: ->
    free = do @game.map.all_free
    if free.length > 1
      @points = [free[random_int 1, free.length-1]]
      log "food at [#{@points[0]}]"
    else
      do @game.stop
      @game.over = yes
      @game.msg_bottom.show 'WOOOOOW!!!<br> Snake has max size'
    return
