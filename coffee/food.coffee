class Food extends GameObject
  color: "green"

  constructor: (@game) ->
    do @respawn
    do @draw

  respawn: ->
    free = do @game.map.all_free
    if free.length > 0
      @points = [free[random_int 1, free.length-1]]
      log "food at [#{@points[0]}]"
    else  
      @game.over = yes
      @game.msg.show "WOW!!! snake has max size"
