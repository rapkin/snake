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
    cur = localStorage.getItem 'high_score'
    localStorage.setItem 'high_score', @value if @value > cur
    do @update_high
    return

  update_high: ->
    local = localStorage.getItem 'high_score'
    @tag_high.textContent = local if local
    return
