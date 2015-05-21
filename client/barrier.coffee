class Barrier extends GameObject
  color: '#292929'

  constructor: (@game) ->
    @game.msg_top.tag.parentElement.style.display = 'block'
    @points = []
    points = window.barrier or []
    for p in points
      _p = @get p[0], p[1]
      @set _p if _p? and _p.obj is @game.map

  unset: (point) ->
    @points.splice @points.indexOf(point), 1
    @game.map.unset point
