class Food extends GameObject
  color: "#7e7"

  constructor: (@game) ->
    ok = no
    loop
      x = random_int 0, @game.width
      y = random_int 0, @game.height
      points = [[x,y]]
      for point in @game.snake.points
        unless point is points[0]
          ok = yes
          break
      break if ok
    @points = points
    do @draw
    log "food at [#{@points[0]}]"
