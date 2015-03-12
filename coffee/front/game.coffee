class Game
  ESC: [27, 13, 32]
  LAYOUT: [76]
  LEFT: [37, 65]
  RIGHT: [39, 68]
  UP: [38, 87]
  DOWN: [40, 83]
  left_right: 1
  up_right_down_left: 2

  last: Date.now()
  now: 0
  delta: 0

  constructor: (@width = 30, @height = 30, @size = 12, speed = 5, layout = @left_right) ->
    @over = no

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
    @barrier = new Barrier @
    @snake = new Snake @
    @food = new Food @
    @layout = layout
    @interval = do @get_interval
    
    window.captureEvents Event.KEYPRESS
    window.onkeydown = @interupt
    do @stop
    do @snake.draw
    return

  interupt: (e) =>
    e = e or window.event
    key = e.which
    if @over then do @new
    else
      if key in @LAYOUT then do @switch_layout
      if @started
        if @layout is @left_right
          if key in @LEFT then @snake.turn 'l'
          if key in @RIGHT then @snake.turn 'r'

        else if @layout is @up_right_down_left
          if key in @LEFT then @snake.try 'l'
          if key in @RIGHT then @snake.try 'r'
          if key in @UP then @snake.try 'u'
          if key in @DOWN then @snake.try 'd'

        if key in @ESC then do @stop

      else
        if key in @UP
          do @speed.up
          @interval = do @get_interval
        if key in @DOWN
          do @speed.down
          @interval = do @get_interval
        if key in @ESC then do @start
    return

  switch_layout: ->
    if @layout is @left_right
      @msg_top.show 'Layout switched to &#9650;&#9654;&#9660;&#9664;', 1.1
      @layout = @up_right_down_left
    else if @layout is @up_right_down_left
      @msg_top.show 'Layout switched to &#9664;&#9654;', 1.1
      @layout = @left_right
    return

  stop: ->
    @msg_bottom.show 'Press <b>Space/Enter/Esc</b> to start'
    @started = no
    return

  start: ->
    @last = Date.now()
    do @main_loop
    @started = yes
    do @msg_bottom.hide
    return

  main_loop: =>
    requestAnimationFrame @main_loop
    @now = Date.now()
    @delta = @now - @last
    if @started and @delta > @interval
      do @snake.move
      do @snake.draw
      @last = @now - (@delta % @interval)
    return

  get_interval: ->
    1000/@speed.value/2

  new: (width = @width, height = @height, size = @size, speed = @speed.value, layout = @layout) ->
    do @stop
    @constructor width, height, size, speed, layout
    return
