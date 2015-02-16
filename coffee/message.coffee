class Message
  constructor: ->
    @tag = $ "msg"
    return

  show: (@text) ->
    @tag.innerHTML = @text
    do @hide
    @tag.setAttribute "class", "msg_show"
    return

  hide: ->
    @tag.setAttribute "class", "msg_hide"
    return
