class Game
  key:
    enter: 13
    clear: 67
    plus: 187
    minus: 189
    higher: 190
    lower: 188
    ESC: [13, 27, 32]
    EDIT: [69]
    LAYOUT: [76]
    LEFT: [37, 65]
    RIGHT: [39, 68]
    UP: [38, 87]
    DOWN: [40, 83]

  layout:
    now: 1
    left_right: 1
    up_right_down_left: 2

  last: Date.now()
  now: 0
  delta: 0
  edit_mode: no

  constructor: (@width = 30, @height = 30, @size = 12, speed = 5) ->
    @over = no
    @win = no
    @height = 4 if @height < 4
    @width = 4 if @width < 4
    @size = 4 if @size < 4

    @wrapper = $ 'game'
    @canvas = $ 'game_canvas'
    do @canvas.remove if @canvas?
    @canvas = document.createElement 'canvas'
    @canvas.setAttribute 'id', 'game_canvas'
    @wrapper.appendChild @canvas

    @msg_top = new Message $ 'msg_top'
    @msg_bottom = new Message $ 'msg_bottom'
    @speed = new Speed @, speed
    @score = new Score @
    @map = new Map @
    @snake = new Snake @
    @barrier = new Barrier @
    @food = new Food @
    @interval = @get_interval()

    do @stop
    do @map.draw
    
    window.captureEvents Event.KEYPRESS
    window.onkeydown = @interupt

  interupt: (e) =>
    e = e or window.event
    key = e.which
    if @edit_mode
      @barrier.key_action key
    else
      if key in @key.EDIT then do @edit
      if @over
        if key in @key.ESC then do @new
      else
        if key in @key.LAYOUT then do @switch_layout
        if @started
          if @layout.now is @layout.left_right
            if key in @key.LEFT then @snake.turn 'l'
            if key in @key.RIGHT then @snake.turn 'r'

          else if @layout.now is @layout.up_right_down_left
            if key in @key.LEFT then @snake.try 'l'
            if key in @key.RIGHT then @snake.try 'r'
            if key in @key.UP then @snake.try 'u'
            if key in @key.DOWN then @snake.try 'd'

          if key in @key.ESC then do @stop
        else if key in @key.ESC then do @start
    return

  switch_layout: ->
    if @layout.now is @layout.left_right
      @msg_top.show 'Layout switched to &#9650;&#9654;&#9660;&#9664;', 1.1
      @layout.now = @layout.up_right_down_left
    else if @layout.now is @layout.up_right_down_left
      @msg_top.show 'Layout switched to &#9664;&#9654;', 1.1
      @layout.now = @layout.left_right
    return

  stop: ->
    @msg_bottom.show 'Press <b>Space/Enter/Esc</b> to start'
    @started = no
    return

  start: ->
    @last = Date.now()
    do @main_loop
    do @msg_bottom.hide
    @started = yes
    return

  edit: ->
    @edit_mode = yes
    do @new

  main_loop: =>
    requestAnimationFrame @main_loop
    @now = Date.now()
    @delta = @now - @last
    if @started and @delta > @interval
      do @snake.move
      do @map.draw
      @last = @now - (@delta % @interval)
    return

  get_interval: -> 1000/@speed.value/2

  new: (width = @width, height = @height, size = @size, speed = @speed.value) ->
    @constructor width, height, size, speed

    if @edit_mode
      do @food.unset
      do @barrier.start_edit
      do @map.draw
