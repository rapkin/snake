class Score
  constructor: (@game) ->
    @tag = $ 'score'
    @value = 0
    @tag.textContent = @value

  next: ->
    @value += @game.speed.value
    @tag.textContent = @value
