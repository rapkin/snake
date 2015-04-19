class Barrier extends GameObject
  color: '#333'

  constructor: (@game) ->
    @game.msg_top.tag.parentElement.style.display = 'block'
    @points = []
    points = window.barrier or []
    for p in points
      _p = @get p[0], p[1]
      @set _p if _p? and _p.obj is @game.map

  start_edit: ->
    log '# eddit mode'.toUpperCase()
    @clear = no
    do @game.msg_bottom.hide
    @game.msg_top.tag.parentElement.style.display = 'none'
    @game.canvas.style.cursor = 'crosshair'

    @game.canvas.onclick = (e) =>
      @mouse_action e
    @game.canvas.onmousedown = (e) =>
      @game.canvas.onmousemove = (e) =>
        @mouse_action e
      @game.canvas.onmouseup = (e) =>
        @game.canvas.onmousemove = null

  stop_edit: ->
    @game.canvas.onkeydown = null
    @game.canvas.onclick = null
    @game.canvas.onmousedown = null
    @game.canvas.onmouseup = null
    @game.canvas.onmousemove = null

  mouse_action: (e) ->
    x = Math.floor e.offsetX/@game.size + 1
    y = Math.floor e.offsetY/@game.size + 1

    point = @get x-1, y-1
    if @clear
      if point.obj is @
        @unset point
    else
      if point.obj is @game.map
        @set point
    do @game.map.draw

  key_action: (key) =>
    if key is @game.key.clear then @clear = not @clear
    if key is @game.key.plus then @change_game_param 'size', 1
    if key is @game.key.minus then @change_game_param 'size', -1
    if key in @game.key.UP then @change_game_param 'height', -1
    if key in @game.key.RIGHT then @change_game_param 'width', 1
    if key in @game.key.DOWN then @change_game_param 'height', 1
    if key in @game.key.LEFT then @change_game_param 'width', -1
    if key is @game.key.higher then do @game.speed.up
    if key is @game.key.lower then do @game.speed.down
    if key in @game.key.ESC
      if key is @game.key.enter then do @serialize
      @game.edit_mode = no
      do @game.new

  unset: (point) ->
    @points.splice @points.indexOf(point), 1
    @game.map.unset point

  serialize: ->
    window.barrier = []
    for point in @points
      window.barrier.push [point.x, point.y]
    return

  change_game_param: (param, value) ->
    @game[param] += value
    do @serialize
    do @game.new
