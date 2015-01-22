class Message
  constructor: ->
    @tag = $ "msg"

  show: (@text) ->
    @tag.innerHTML = @text
    do @hide
    @tag.setAttribute "class", "msg_show"

  hide: ->
    @tag.setAttribute "class", "msg_hide"