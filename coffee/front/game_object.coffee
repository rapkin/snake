class GameObject
  points: []
  color: '#fff'
  
  draw: (points = @points, color = @color) ->
    @game.g.fillStyle = color
    for p in points
      @game.g.fillRect p[0]*@game.size+1, p[1]*@game.size+1, @game.point_size, @game.point_size
    return
