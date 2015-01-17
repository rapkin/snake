window.onload = ->
  window.game = new Game 20, 20, 15
  game.SPEED = 13
  do game.start
  return