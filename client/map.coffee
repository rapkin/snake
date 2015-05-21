class Map
  color: '#363636'

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
        p = x: i, y: k, obj: @
        @points[i][k] = p
        @set p, @

    log "Map #{@game.width}x#{@game.height} created!"
    do @draw

  get: (x, y) ->
    return @points[x][y] if 0 <= x < @game.width and 0 <= y < @game.height
    warn "Undefined coordinate [#{x}, #{y}]"
    return null

  set: (point, obj) ->
    return null unless point?
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
    @updated.push point if point not in @updated

  draw: ->
    while @updated.length > 0
      p = @updated.pop()
      @draw_point p
    return

  draw_point: (p, color = p.obj.color) ->
    g = @game.g
    g.fillStyle = color
    g.strokeStyle = color
    g.lineJoin = 'round'
    r = g.lineWidth = 3

    x = p.x*@game.size+1
    y = p.y*@game.size+1
    w = @game.point_size
    h = @game.point_size

    if p.obj is @
      g.fillRect x-1, y-1, w+2, h+2
      return

    args = [x+r / 2, y+r / 2, w-r, h-r]
    g.strokeRect args...
    g.fillRect args...
