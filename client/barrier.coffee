class Barrier extends GameObject
  color: '#333'

  constructor: (@game) ->
    @game.msg_top.tag.parentElement.style.display = 'block'
    @points = []
    points = window.barrier or []
    for p in points
      @set @get p[0], p[1]

  start_edit: ->
    log '# eddit mode'.toUpperCase()
    do @game.msg_bottom.hide
    @game.msg_top.tag.parentElement.style.display = 'none'
    @game.canvas.onclick = (e) =>
      x = Math.floor e.offsetX/@game.size + 1
      y = Math.floor e.offsetY/@game.size + 1

      point = @get x-1, y-1
      if point.obj is @
        @unset point
      else if point.obj is @game.map
        @set point
      do @game.map.draw

  unset: (point) ->
    @points.splice @points.indexOf(point), 1
    @game.map.unset point

  serialize: ->
    window.barrier = []
    for point in @points
      window.barrier.push [point.x, point.y]
