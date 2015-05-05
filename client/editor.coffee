class Editor
  enabled: no
  barrier: null

  # FIXME PLEASE

  constructor: (@game) ->
    @game.editor = @
    @key = @game.key
    @title = tag: $ 'title'

  reset_title: ->
    @title.tag.children[0].remove() if @title.tag.childElementCount
    @title.edit = document.createElement 'span'
    @title.edit.innerHTML = ' (edit mode)'
    @title.tag.appendChild @title.edit if @editor.enabled

  start: ->
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
      @game.canvas.onmouseleave =
      @game.canvas.onmouseup = (e) =>
        @press = no

  stop_edit: ->
    @enabled = no
    @game.canvas.onkeydown = null
    @game.canvas.onclick = null
    @game.canvas.onmousedown = null
    @game.canvas.onmouseup = null
    @game.canvas.onmousemove = null

  mouse_action: (e) ->
    rect = @game.canvas.getBoundingClientRect()
    x = Math.floor (e.clientX - rect.left)/@game.size + 1
    y = Math.floor (e.clientY - rect.top)/@game.size + 1

    point = @game.map.get x-1, y-1
    if @press or @click
      @click = no if @click
      if @clear
        if point.obj is @game.barrier
          @game.barrier.unset point
      else
        if point.obj is @game.map
          @game.barrier.set point
      do @game.map.draw
    @set_mask point

  set_mask: (point) ->
    color = 'rgba(0,255,0,.4)'
    color = 'rgba(255,150,0,.4)' if @clear
    if @mask.length
      last = @mask.pop()
      last_obj = last.obj
      last.obj = @game.map
      @game.map.draw_point last
      last.obj = last_obj
      @game.map.draw_point last

    if point.obj in [@game.map, @game.barrier]
      @mask.push point
      cur_obj = point.obj
      point.obj = color: color
      @game.map.draw_point point
      point.obj = cur_obj

  key_action: (key) =>
    if key is @key.clear
      @clear = not @clear
      @set_mask @mask[0]
    if key is @key.plus then @change_game_param 'size', 1
    if key is @key.minus then @change_game_param 'size', -1
    if key in @key.UP then @change_game_param 'height', -1
    if key in @key.RIGHT then @change_game_param 'width', 1
    if key in @key.DOWN then @change_game_param 'height', 1
    if key in @key.LEFT then @change_game_param 'width', -1
    if key is @key.higher then do @game.speed.up
    if key is @key.lower then do @game.speed.down
    if key in @key.ESC
      if key is @key.enter then do @serialize
      do @game.new
    do @stop_edit

  save_barrier: ->
    window.barrier_tmp = []
    for p in @game.barrier.points
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
