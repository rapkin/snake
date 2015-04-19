class Speed
  constructor: (@game, @value) ->
    @tag = value_tag $ 'speed'
    do @show

  show: ->
    @tag.textContent = @value
    return

  up: ->
    unless @value >= 30
      @value+=1
      @game.interval = @game.get_interval()
      do @show
    return

  down: ->
    unless @value <= 1
      @value-=1
      @game.interval = @game.get_interval()
      do @show
    return
