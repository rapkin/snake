class Game
  ESC: [27, 13, 32]
  LEFT: [37, 65]
  RIGHT: [39, 68]
  UP: [38, 87]
  DOWN: [40, 83]

  constructor: (@width = 30, @height = 30, @size = 12, speed = 5) ->
    @over = no

    @wrapper = $ "game"
    @canvas = $ "game_canvas"
    if @canvas? then do @canvas.remove
    @canvas = document.createElement "canvas"
    @canvas.setAttribute "id", "game_canvas"
    @wrapper.appendChild @canvas

    @msg = new Message
    @speed = new Speed @, speed 
    @score = new Score @
    @map = new Map @
    @snake = new Snake @
    @food = new Food @
    
    window.captureEvents Event.KEYPRESS
    window.onkeydown = @interupt.bind @
    do @stop

  interupt: (e) ->
    e = e || window.event
    key = e.which
    if @over
      if key is 82 then do @new
    else
      if key in @ESC 
        if @started then do @stop
        else do @start
      if key in @LEFT then do @snake.turn_left
      if key in @RIGHT then do @snake.turn_right
      if not @started
        if key in @UP then do @speed.up
        if key in @DOWN then do @speed.down
    return

  stop: ->
    @msg.show "Press <b>Space/Enter/Esc</b> to start"
    clearInterval @interval
    @started = no
    return

  start: ->
    @interval = setInterval @main_loop.bind(@), 1000/@speed.value/2
    @started = yes
    do @msg.hide
    return

  main_loop: ->
    do @snake.move
    do @snake.draw
    do @food.draw
    return

  new: (width = @width, height = @height, size = @size, speed = @speed.value) ->
    do @stop
    @constructor width, height, size, speed
