class Score
  constructor: (@game) ->
    @tag = value_tag $ 'score'
    @tag_high = value_tag $ 'high_score'
    @set 0
    @set_high @game.score?.high ? 0

  set: (@value) -> do @update
  set_high: (@high) -> do @update_high

  update: -> @tag.textContent = @value
  update_high: -> @tag_high.textContent = @high

  next: -> @set @value + @game.speed.value

  new_high: ->
    if @value > @high
      @high = @value
      ajax "/save_score#{window.location.pathname}", value: @high
    do @update_high
