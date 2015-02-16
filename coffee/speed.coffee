class Speed
  constructor: (@game, @value) ->
    @tag = $ "speed"
    do @show
    return

  show: ->
    @tag.textContent = @value
    return

  up: ->
    unless @value >= 30 
      @value++
      do @show
    return

  down: ->
    unless @value <= 1 
      @value--
      do @show
    return
    