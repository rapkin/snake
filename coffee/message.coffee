class Message
  constructor: (@tag) ->

  show: (@text, timeout = false) ->
    @tag.innerHTML = @text
    do @hide
    @tag.setAttribute "class", "msg_show"
    if timeout
      @last_time = setTimeout @hide, 1000*timeout
    return

  hide: =>
    clearTimeout @last_time
    @tag.setAttribute "class", "msg_hide"
    return
