class Snake extends GameObject
  head_color: "#e77"
  color: "#ccc"

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
    @direction = @RIGHT
    do @draw

  move: ->
    @tail = do @points.pop
    first = @points[0]
    switch @direction
      when @UP
        if (first[1] > 0) then @points.unshift [first[0],first[1]-1]
        else  @points.unshift [first[0], @game.height-1]
      when @RIGHT
        if (first[0] < @game.width-1) then @points.unshift [first[0]+1,first[1]]
        else  @points.unshift [0, first[1]]
      when @DOWN
        if (first[1] < @game.height-1) then @points.unshift [first[0],first[1]+1]
        else  @points.unshift [first[0], 0]
      when @LEFT
        if (first[0] > 0) then @points.unshift [first[0]-1,first[1]]
        else  @points.unshift [@game.width-1, first[1]]
    return

  turn_left: ->
    if @direction > 1 then @direction--
    else @direction = @LEFT

  turn_right: ->
    if @direction < 4 then @direction++
    else @direction = @UP

  draw: ->
    super
    super [@tail], @game.map.color
    super [@points[0]], @head_color