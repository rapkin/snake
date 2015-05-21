class Message
  constructor: (@tag) ->

  show: (@text, timeout = false) ->
    do @hide
    @tag.innerHTML = @text
    @tag.setAttribute 'class', 'msg_show'
    @last_time = setTimeout @hide, 1000*timeout if timeout

  hide: =>
    clearTimeout @last_time
    @tag.setAttribute 'class', 'msg_hide'
