class Editor
  constructor: (@game) ->
    @game.editor = @
    @key = @game.key
    @enabled = no
    @backup = null
    @title = tag: $ 'title'

  set_title: ->
    @title.edit = document.createElement 'span'
    @title.edit.innerHTML = ' (edit mode)'
    @title.tag.appendChild @title.edit

  unset_title: -> @title.tag.children[0].remove()

  update_game: ->
    do @game.new
    do @game.food.unset
    do @game.map.draw
    do @game.msg_bottom.hide
    @game.canvas.style.cursor = 'crosshair'
    @game.msg_top.tag.parentElement.style.display = 'none'

  start: ->
    log '# EDIT MODE ENABLED'
    @enabled = yes
    @clear = no
    @mask = []
    do @update_game
    do @set_title
    do @backup_level

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

  stop: ->
    log '# EDIT MODE DISABLED'
    do @unset_title
    @enabled = no
    @game.canvas.onkeydown = null
    @game.canvas.onclick = null
    @game.canvas.onmousedown = null
    @game.canvas.onmouseup = null
    @game.canvas.onmousemove = null
    @game.msg_top.tag.parentElement.style.display = 'block'
    do @game.new

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
      if key is @key.enter then do @save
      else do @restore_level
      do @stop

  push_barrier_to: (dest) ->
    for p in @game.barrier.points
      dest.push [p.x, p.y]

  backup_level: ->
    @backup =
      barrier: []
      width: @game.width
      height: @game.height
      speed: @game.speed.value
      size: @game.size
    @push_barrier_to @backup.barrier

  restore_level: ->
    @game.width = @backup.width
    @game.height = @backup.height
    @game.size = @backup.size
    @game.speed.set @backup.speed
    window.barrier = @backup.barrier

  save: ->
    do @backup_level
    window.barrier = @backup.barrier
    ajax "/save_level#{window.location.pathname}", @backup

  change_game_param: (param, value) ->
    @game[param] += value
    window.barrier = []
    @push_barrier_to window.barrier
    do @update_game
