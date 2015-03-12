class Snake extends GameObject
  head_color: 'red'
  color: 'white'

  UP: 1
  RIGHT: 2
  DOWN: 3
  LEFT: 4

  constructor: (@game) ->
    x = Math.floor @game.width/2
    y = Math.floor @game.height/2
    @points = [
      [x, y-2],
      [x, y-1],
      [x, y]
    ]
    @tail = [x, y+1]
    @stack = []
    @direction = @UP
    return

  move: ->
    do @step
    x = @points[0][0]
    y = @points[0][1]
    
    switch @direction
      when @UP
        if y > 0 then next = [x, y-1]
        else  next = [x, @game.height-1]
      when @RIGHT
        if x < @game.width-1 then next = [x+1, y]
        else  next = [0, y]
      when @DOWN
        if y < @game.height-1 then next = [x, y+1]
        else  next = [x, 0]
      when @LEFT
        if x > 0 then next = [x-1, y]
        else  next = [@game.width-1, y]

    if @is_free(next) or @will_be_tail(next)
      @points.unshift next
      if next[0] is @game.food.points[0][0] and next[1] is @game.food.points[0][1]
        do @game.food.respawn
        do @game.score.next
      else @tail = do @points.pop
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
    for a in @points
      if point[0] is a[0] and point[1] is a[1] then return no
    for b in @game.barrier.points
      if point[0] is b[0] and point[1] is b[1] then return no
    return yes

  will_be_tail: (point) ->
    tail = @points[@points.length - 1]
    return yes if point[0] is tail[0] and point[1] is tail[1]
    return no

  draw: ->
    super
    super [@tail], @game.map.color
    do @game.food.draw
    super [@points[0]], @head_color
    return
