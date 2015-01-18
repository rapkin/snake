class Map extends GameObject
  color: "#222"

  constructor: (@game) ->
    @game.g = @game.canvas.getContext '2d'
    @game.canvas.width = (@game.width) * @game.size
    @game.canvas.height = (@game.height) * @game.size
    @game.wrapper.style.width = "#{@game.canvas.width}px"
    @game.wrapper.style.height = "#{@game.canvas.height}px"
    w = [0...@game.width]
    h = [0...@game.height]
    j = 0
    for i in w
      for k in h
        @points[j++] = [w[i],h[k]]
    @game.point_size = @game.size - 2
    do @draw_ground
    log "Map #{@game.width}x#{@game.height} created!"

  draw_ground: ->
    @game.g.fillStyle = "#111"
    @game.g.fillRect 0, 0, @game.canvas.width, @game.canvas.height
    do @draw
