class Game
  SPEED: 5
  ESC: [27, 13, 32]
  LEFT: [37, 65]
  RIGHT: [39, 68]
  UP: [38, 87]
  DOWN: [40, 83]

  constructor: (@width = 30, @height = 30, @size = 12) ->
    @started = no
    @map = new Map(this, $ "game_map")
    @snake = new Snake(this)
    @food = new Food(this)

  interupt: (e) ->
    unless e
      if @started is yes
        clearInterval @interval
        @started = no
      else
        @interval = setInterval main_loop_help, 1000/@SPEED
        log "speed is #{@SPEED} point/sec"
        @started = yes
      return
    else
      e = e || window.event
      key = e.which || e.keyCode
      if key in @ESC then do @interupt
      if key in @LEFT then do @snake.turn_left
      if key in @RIGHT then do @snake.turn_right
      if key in @UP
        do @interupt
        @SPEED++ if @SPEED < 60
        do @interupt
      if key in @DOWN
        do @interupt
        @SPEED-- if @SPEED > 1
        do @interupt
      return

  main_loop: ->
    do @snake.move
    do @snake.draw
    return
