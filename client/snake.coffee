class Snake extends GameObject

  class Head extends GameObject
    color: '#C13D36'
    constructor: (@game) -> @points = []

    set: (point) ->
      if @points.length > 0
        tmp = @points[0]
        do @unset
        @game.snake.set tmp
      super point

  color: '#D58581'

  UP: 1
  RIGHT: 2
  DOWN: 3
  LEFT: 4

  constructor: (@game) ->
    @head = new Head @game
    @points = []
    @stack = []
    @direction = @UP

    x = Math.floor @game.width/2
    y = Math.floor @game.height/2

    @set @get x, y
    @set @get x, y-1
    @head.set @get x, y-2

  move: ->
    do @step
    next = @get_next()

    @food = no
    @food = yes if next.obj is @game.food
    if @food
      do @game.food.respawn
      do @game.score.next

    if @is_free(next) or @will_be_tail next
      do @unset if not @food
      @head.set next

      if @game.win
        @game.started = no
        @game.over = yes
        @game.msg_bottom.show 'WOOOOOW!!!<br> Snake has max size'
    else
      @game.started = no
      @game.over = yes
      do @game.score.new_high

      unless @game.win
        @game.msg_bottom.show """
          GAME OVER! Your score <b>#{@game.score.value}</b>.
          <br>Press <b>Space/Enter/Esc</b> to restart
        """

  get_next: ->
    x = @head.points[0].x
    y = @head.points[0].y

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
    return @get x, y

  step: ->
    if @stack[0]
      turn = @stack.shift()
      if turn is 'r'
        if @direction < 4 then @direction+=1
        else @direction = @UP
      else if turn is 'l'
        if @direction > 1 then @direction-=1
        else @direction = @LEFT

  turn: (dir = 'l') -> @stack.push dir

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

  is_free: (point) -> point.obj is @game.map or @food

  will_be_tail: (point) -> point is @points[@points.length - 1]
