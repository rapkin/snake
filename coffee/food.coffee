class Food extends GameObject
  color: "#7e7"

  constructor: (@game) ->
    do @spawn
    do @draw

  spawn: ->
    free = intersec_arrays @game.map.points, @game.snake.points, arr_comp
    if free.length > 0
      @points = [free[random_int(1, free.length-1)]]
      log "food at [#{@points[0]}]"
    else  
      @game.over = yes
      log "game finished, snake has max size"

  remove: ->
    @draw @points, @game.map.color
    @points = []

  respawn: ->
    do @remove
    do @spawn
