class Score
  value: 0

  constructor: (@game, @tag) ->
    @tag.textContent = @value

  next: ->
    @value += @game.SPEED
    @tag.textContent = @value
    