class Barrier extends GameObject
  color: '#292929'

  constructor: (@game) ->
    @game.msg_top.tag.parentElement.style.display = 'block'
    @points = []
    points = window.barrier_tmp or window.barrier or []
    for p in points
      _p = @get p[0], p[1]
      @set _p if _p? and _p.obj is @game.map

  start_edit: ->
    log '# EDIT MODE'
    @mask = []
    @clear = no
    do @save_barrier
    do @game.msg_bottom.hide
    @game.msg_top.tag.parentElement.style.display = 'none'
    @game.canvas.style.cursor = 'crosshair'

    @game.canvas.onclick = (e) =>
      @click = yes
      @mouse_action e
    @game.canvas.onmousemove = (e) =>
      @mouse_action e
    @game.canvas.onmousedown = (e) =>
      @press = yes
      @game.canvas.onmouseup = (e) =>
        @press = no

  stop_edit: ->
    @game.canvas.onkeydown = null
    @game.canvas.onclick = null
    @game.canvas.onmousedown = null
    @game.canvas.onmouseup = null
    @game.canvas.onmousemove = null

  mouse_action: (e) ->
    rect = @game.canvas.getBoundingClientRect()
    x = Math.floor (e.clientX - rect.left)/@game.size + 1
    y = Math.floor (e.clientY - rect.top)/@game.size + 1

    point = @get x-1, y-1
    if @press or @click
      @click = no if @click
      if @clear
        if point.obj is @
          @unset point
      else
        if point.obj is @game.map
          @set point
      do @game.map.draw
    @set_mask point

  set_mask: (point) ->
    color = 'rgba(0,255,0,.4)'
    color = 'rgba(255,150,0,.4)' if @clear
    if @mask.length
      last = @mask.pop()
      @game.map.draw_point last
    @mask.push point
    @game.map.draw_point point, color

  key_action: (key) =>
    if key is @game.key.clear
      @clear = not @clear
      @set_mask @mask[0]
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

  save_barrier: ->
    window.barrier_tmp = []
    for p in @points
      window.barrier_tmp.push [p.x, p.y]
    return

  serialize: ->
    window.barrier = []
    for p in @points
      window.barrier.push [p.x, p.y]
    window.barrier_tmp = null

    ajax "/save_level#{window.location.pathname}",
      width: @game.width
      height: @game.height
      size: @game.size
      speed: @game.speed.value
      barrier: window.barrier or []
    return

  change_game_param: (param, value) ->
    @game[param] += value
    do @save_barrier
    do @game.new
