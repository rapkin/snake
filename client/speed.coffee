class Speed
  constructor: (@game) ->
    @tag = value_tag $ 'speed'
    @set 5

  set: (@value) -> @tag.textContent = @value

  up: ->
    if @value < 30
      @set @value + 1
      do @game.update_interval

  down: ->
    if @value > 1
      @set @value - 1
      do @game.update_interval
