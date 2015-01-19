class Score
  constructor: (@game, @tag) ->
    @value = 0
    @tag.textContent = @value

  next: ->
    @value += @game.SPEED
    @tag.textContent = @value
    