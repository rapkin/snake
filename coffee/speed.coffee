class Speed
  constructor: (@game, @value) ->
    @tag = $ "speed"
    do @show

  show: ->
    @tag.textContent = @value

  up: ->
    unless @value >= 30 
      @value++
      do @show

  down: ->
    unless @value <= 1 
      @value--
      do @show
    