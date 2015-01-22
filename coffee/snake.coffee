class Snake extends GameObject
  head_color: "red"
  color: "white"

  UP: 1
  RIGHT: 2
  DOWN: 3
  LEFT: 4

  constructor: (@game) ->
    x = Math.floor @game.width/2
    y = Math.floor @game.height/2
    @points = [
      [x,y-1],
      [x,y],
      [x,y+1]
    ]
    @tail = [x-1,y+1]
    @direction = @UP
    do @draw

  move: ->
    x = @points[0][0]
    y = @points[0][1]
    switch @direction
      when @UP
        if y > 0 then next = [x,y-1]
        else  next = [x, @game.height-1]
      when @RIGHT
        if x < @game.width-1 then next = [x+1,y]
        else  next = [0, y]
      when @DOWN
        if y < @game.height-1 then next = [x,y+1]
        else  next = [x, 0]
      when @LEFT
        if x > 0 then next = [x-1,y]
        else  next = [@game.width-1, y]

    if @is_free next
      @points.unshift next
      if next[0] is @game.food.points[0][0] and next[1] is @game.food.points[0][1] 
        do @game.food.respawn
        do @game.score.next
      else @tail = do @points.pop
    else
      @game.started = no
      @game.over = yes
      do @game.stop
      @game.msg.show "GAME OVER! Your score <b>#{@game.score.value}</b>.<br>Press <b>R</b> to restart"
    return

  turn_left: ->
    if @direction > 1 then @direction--
    else @direction = @LEFT

  turn_right: ->
    if @direction < 4 then @direction++
    else @direction = @UP

  is_free: (point) ->
    for a in @points
      if a[0] is point[0] and a[1] is point[1]
        return no
    return yes

  draw: ->
    super
    super [@tail], @game.map.color
    super [@points[0]], @head_color
    