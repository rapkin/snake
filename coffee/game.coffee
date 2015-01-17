class Game
  SPEED: 5
  ESC: [27, 13, 32]
  LEFT: [37, 65]
  RIGHT: [39, 68]
  UP: [38, 87]
  DOWN: [40, 83]

  constructor: (@width = 30, @height = 30, @size = 12) ->
    @canvas = document.createElement "canvas"
    @wrapper = $ "game"
    @wrapper.appendChild @canvas
    @started = no
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
    else
      e = e || window.event
      key = e.which || e.keyCode
      if key in @ESC then do @interupt
      if key in @LEFT then do @snake.turn_left
      if key in @RIGHT then do @snake.turn_right
      if key in @UP
        do @interupt
        @SPEED+=2 if @SPEED < 60
        do @interupt
      if key in @DOWN
        do @interupt
        @SPEED-=2 if @SPEED > 2
        do @interupt
      return

  stop: ->
    clearInterval @interval
    @started = no

  start: ->
    @interval = setInterval @main_loop.bind(@), 1000/@SPEED
    log "speed is #{@SPEED} point/sec"
    @started = yes

  main_loop: ->
    do @snake.move
    do @snake.draw
    do @food.draw
    return
