class Map extends GameObject
  color: '#222'

  constructor: (@game) ->
    @points = []
    @game.g = @game.canvas.getContext '2d'
    @game.canvas.width = (@game.width) * @game.size
    @game.canvas.height = (@game.height) * @game.size
    @game.wrapper.style.width = "#{@game.canvas.width}px"
    @game.wrapper.style.height = "#{@game.canvas.height}px"
    j = -1
    for i in [0...@game.width]
      for k in [0...@game.height]
        @points[j+=1] = [i, k]
    @game.point_size = @game.size - 2
    do @draw
    log "Map #{@game.width}x#{@game.height} created!"
    return

  all_free: ->
    j = -1
    free = []
    for a in @points
      free[j+=1] = a if @game.snake.is_free a
    return free
