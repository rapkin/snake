class Score
  constructor: (@game) ->
    @tag = value_tag $ 'score'
    @tag_high = value_tag $ 'high_score'
    @value = 0
    @tag.textContent = @value
    do @update_high

  next: ->
    @value += @game.speed.value
    @tag.textContent = @value

  set_high: ->
    if @value > window.high_score
      window.high_score = @value
      req = getXmlHttp()
      ajax "/save_score#{window.location.pathname}", value: @value
    do @update_high
    return

  update_high: ->
    @tag_high.textContent = window.high_score
    return
