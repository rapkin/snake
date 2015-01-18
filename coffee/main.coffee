window.onload = ->
  window.game = new Game 20, 20, 20
  game.SPEED = 4
  do game.start
  return