class Map
  color: '#222'

  constructor: (@game) ->
    @points = []
    @updated = []
    @free = []
    @game.point_size = @game.size - 2
    @game.g = @game.canvas.getContext '2d'
    @game.canvas.width = (@game.width) * @game.size
    @game.canvas.height = (@game.height) * @game.size
    @game.wrapper.style.width = "#{@game.canvas.width}px"
    @game.wrapper.style.height = "#{@game.canvas.height}px"

    for i in [0...@game.width]
      @points[i] = []
      for k in [0...@game.height]
        p =
          x: i
          y: k
          obj: @

        @points[i][k] = p
        @set p, @

    log "Map #{@game.width}x#{@game.height} created!"
    do @draw
    return

  get: (x, y) ->
    if x >= @game.width or y >= @game.height
      log "Undefined coordinate [#{x}, #{y}]"
      return
    return @points[x][y]

  set: (point, obj) ->
    point.obj = obj
    @update point
    if obj is @
      @free.push point
      return
    unfree = @free.splice @free.indexOf(point), 1
    return unfree[0]

  unset: (point) ->
    @set point, @
    @update point

  update: (point) ->
    @updated.push point

  draw: ->
    while @updated.length > 0
      p = @updated.pop()
      @game.g.fillStyle = p.obj.color
      @game.g.fillRect p.x*@game.size+1, p.y*@game.size+1, @game.point_size, @game.point_size
    return
