class GameObject
  points: []
  color: "#fff"
  
  draw: (points = @points, color = @color) ->
    @game.g.fillStyle = color
    for point in points
      @game.g.fillRect point[0]*@game.size+1, point[1]*@game.size+1, @game.point_size, @game.point_size
    return