class Speed
  constructor: (@game, @value) ->
    @tag = $ "speed"
    do @show
    return

  show: ->
    @game.msg_top.show "Speed is #{@value}", 1,3
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
    