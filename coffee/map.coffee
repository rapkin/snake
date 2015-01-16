class Map extends GameObject
  color: "#444"

  constructor: (@game, @tag) ->
    @game.g = @tag.getContext '2d'
    @tag.width = (@game.width) * @game.size
    @tag.height = (@game.height) * @game.size
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
    @game.g.fillStyle = "#333"
    @game.g.fillRect 0, 0, @tag.width, @tag.height
    do @draw

