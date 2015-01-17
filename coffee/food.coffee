class Food extends GameObject
  color: "#7e7"

  constructor: (@game) ->
    do @spawn
    do @draw

  spawn: ->
    ok = no
    loop
      x = random_int 0, @game.width-1
      y = random_int 0, @game.height-1
      points = [[x,y]]
      unless points[0] in @game.snake.points or points[0] is @game.snake.tail then break
    @points = points
    log "food at [#{@points[0]}]"

  remove: ->
    @draw @points, @game.map.color
    @points = []

  respawn: ->
    do @remove
    do @spawn
