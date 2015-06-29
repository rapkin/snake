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
    now: 2
    left_right: 1
    up_right_down_left: 2

  last: Date.now()
  now: 0
  delta: 0

  constructor: (@width = 30, @height = 30, @size = 12, speed = 5) ->
    @over = no
    @win = no

    @height = 4 if @height < 4
    @width = 4 if @width < 4
    @size = 4 if @size < 4

    do @init_objects
    @speed.set speed
    do @update_interval
    do @map.draw
    do @stop

    if @map.free.length is 0
      @over = yes
      @msg_bottom.show '''
        <b>DONT MAKE LVL LIKE THIS!!!</b><br>
        Edit please (press <b>E</b>)
        '''
    window.captureEvents Event.KEYPRESS
    window.onkeydown = @interupt

  init_objects: ->
    @wrapper = $ 'game'
    @canvas = $ 'game_canvas'
    @editor = @editor ? enabled: false
    @msg_top = new Message $ 'msg_top'
    @msg_bottom = new Message $ 'msg_bottom'
    @speed = new Speed @
    @score = new Score @
    @map = new Map @
    @snake = new Snake @
    @barrier = new Barrier @
    @food = new Food @

  interupt: (e) =>
    e = e or window.event
    key = e.which
    if @editor.enabled
      @editor.key_action key
    else
      if key in @key.EDIT then do @editor.start
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

  switch_layout: ->
    if @layout.now is @layout.left_right
      @msg_top.show 'Layout switched to &#9650;&#9654;&#9660;&#9664;', 1.1
      @layout.now = @layout.up_right_down_left
    else if @layout.now is @layout.up_right_down_left
      @msg_top.show 'Layout switched to &#9664;&#9654;', 1.1
      @layout.now = @layout.left_right

  stop: ->
    @msg_bottom.show 'Press <b>Space/Enter/Esc</b> to start'
    @started = no

  start: ->
    @last = Date.now()
    @started = yes
    do @main_loop
    do @msg_bottom.hide

  main_loop: =>
    if @started
      requestAnimationFrame @main_loop
      @now = Date.now()
      @delta = @now - @last
      if @delta > @interval
        do @snake.move
        do @map.draw
        @last = @now - (@delta % @interval)

  update_interval: -> @interval = 1000/@speed.value/2

  new: (width = @width, height = @height, size = @size, speed = @speed.value) ->
    @constructor width, height, size, speed
