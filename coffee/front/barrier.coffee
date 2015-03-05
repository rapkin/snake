class Barrier extends GameObject
  color: '#666'

  constructor: (@game, @points = []) ->
    @points = window.barrier or []
    do @draw
