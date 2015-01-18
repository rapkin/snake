class Game
  SPEED: 5
  ESC: [27, 13, 32]
  LEFT: [37, 65]
  RIGHT: [39, 68]
  UP: [38, 87]
  DOWN: [40, 83]

  constructor: (@width = 30, @height = 30, @size = 12) ->
    @over = no
    @wrapper = $ "game"
    @canvas = $ "game_canvas"
    if @canvas? then do @canvas.remove
    @canvas = document.createElement "canvas"
    @canvas.setAttribute "id", "game_canvas"
    @wrapper.appendChild @canvas
    @started = no
    @score = new Score(this, $ "score")
    @map = new Map(this)
    @snake = new Snake(this)
    @food = new Food(this)
    window.captureEvents Event.KEYPRESS
    window.onkeydown = @interupt.bind @

  interupt: (e) ->
    unless e
      if @started is yes then do @stop
      else do @start
      return
    else if not @over
      e = e || window.event
      key = e.which || e.keyCode
      if key in @ESC then do @interupt
      if key in @LEFT then do @snake.turn_left
      if key in @RIGHT then do @snake.turn_right
      if key in @UP
        do @interupt
        @SPEED++ if @SPEED < 30
        do @interupt
      if key in @DOWN
        do @interupt
        @SPEED-- if @SPEED > 1
        do @interupt
      return
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
    @constructor width, height, size
