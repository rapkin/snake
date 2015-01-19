class Map extends GameObject
  color: "#222"

  constructor: (@game) ->
    @points = []
    @game.g = @game.canvas.getContext '2d'
    @game.canvas.width = (@game.width) * @game.size
    @game.canvas.height = (@game.height) * @game.size
    @game.wrapper.style.width = "#{@game.canvas.width}px"
    @game.wrapper.style.height = "#{@game.canvas.height}px"
    j = 0
    for i in [0...@game.width]
      for k in [0...@game.height]
        @points[j++] = [i,k]
    @game.point_size = @game.size - 2
    do @draw_ground
    log "Map #{@game.width}x#{@game.height} created!"

  draw_ground: ->
    @game.g.fillStyle = "#111"
    @game.g.fillRect 0, 0, @game.canvas.width, @game.canvas.height
    do @draw

  all_free: ->
    j = 0
    free = []
    for a in @points
      free[j++] = a if @game.snake.is_free a
    return free
