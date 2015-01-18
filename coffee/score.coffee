class Score
  value: 0

  constructor: (@game, @tag) ->
  next: ->
    @value += @game.SPEED
    @tag.textContent = @value