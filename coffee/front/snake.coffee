class Snake extends GameObject
  head_color: 'red'
  color: 'white'

  UP: 1
  RIGHT: 2
  DOWN: 3
  LEFT: 4

  constructor: (@game) ->
    @points = []
    @stack = []
    @direction = @UP

    x = Math.floor @game.width/2
    y = Math.floor @game.height/2

    @set @get x, y
    @set @get x, y-1
    @set @get x, y-2
    return

  move: ->
    do @step
    x = @points[0].x
    y = @points[0].y
    
    switch @direction
      when @UP
        if y > 0 then y = y-1
        else y = @game.height-1
      when @RIGHT
        if x < @game.width-1 then x = x+1
        else x = 0
      when @DOWN
        if y < @game.height-1 then y = y+1
        else y = 0
      when @LEFT
        if x > 0 then x = x-1
        else  x = @game.width-1

    next = @get x, y
    if next.obj is @game.food
      do @game.food.respawn
      do @game.score.next
    else do @unset

    if @is_free(next) or @will_be_tail(next)
      @set next
    else
      @game.started = no
      @game.over = yes
      do @game.score.set_high
      unless @game.win
        @game.msg_bottom.show "GAME OVER! Your score <b>#{@game.score.value}</b>.
          <br>Press <b>Space/Enter/Esc</b> to restart"
    return

  step: ->
    if @stack[0]
      turn = @stack.shift()
      if turn is 'r'
        if @direction < 4 then @direction+=1
        else @direction = @UP
      else if turn is 'l'
        if @direction > 1 then @direction-=1
        else @direction = @LEFT
    return

  turn: (dir = 'l') ->
    @stack.push dir
    return

  try: (dir = 'l') ->
    switch dir
      when 'l'
        if @direction is @UP then @turn 'l'
        if @direction is @DOWN then @turn 'r'
      when 'r'
        if @direction is @UP then @turn 'r'
        if @direction is @DOWN then @turn 'l'
      when 'u'
        if @direction is @LEFT then @turn 'r'
        if @direction is @RIGHT then @turn 'l'
      when 'd'
        if @direction is @LEFT then @turn 'l'
        if @direction is @RIGHT then @turn 'r'
    return

  is_free: (point) ->
    point.obj is @game.map

  will_be_tail: (point) ->
    tail = @points[@points.length - 1]
    point is tail
