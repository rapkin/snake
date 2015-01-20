class Game
  ESC: [27, 13, 32]
  LEFT: [37, 65]
  RIGHT: [39, 68]
  UP: [38, 87]
  DOWN: [40, 83]

  constructor: (@width = 30, @height = 30, @size = 12, @SPEED = 5) ->
    @over = no
    @started = no
    @wrapper = $ "game"
    @canvas = $ "game_canvas"
    if @canvas? then do @canvas.remove
    @canvas = document.createElement "canvas"
    @canvas.setAttribute "id", "game_canvas"
    @wrapper.appendChild @canvas
    @score = new Score this, $ "score"
    @map = new Map this
    @snake = new Snake this
    @food = new Food this
    window.captureEvents Event.KEYPRESS
    window.onkeydown = @interupt.bind @

  interupt: (e) ->
    e = e || window.event
    key = e.which
    if not @over
      if key in @ESC 
        if @started then do @stop
        else do @start
      if key in @LEFT then do @snake.turn_left
      if key in @RIGHT then do @snake.turn_right
      if 1 < @SPEED < 30 and not @started
        if key in @UP then @SPEED++
        if key in @DOWN then @SPEED--
    else log "game over with score #{@score.value}"

  stop: ->
    clearInterval @interval
    @started = no
    return

  start: ->
    @interval = setInterval @main_loop.bind(@), 1000/@SPEED/2
    log "speed is #{@SPEED}"
    @started = yes
    return

  main_loop: ->
    do @snake.move
    do @snake.draw
    do @food.draw
    return

  new:(width, height, size) ->
    do @stop
    @constructor width, height, size
