class Message
  constructor: (@tag) ->

  show: (@text) ->
    @tag.textContent = @text
    do @hide
    @tag.setAttribute "class", "msg_show"

  hide: ->
    @tag.setAttribute "class", "msg_hide"