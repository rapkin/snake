window.onload = ->
  window.game = new Game 40, 30, 14
  game.SPEED = 10
  do game.interupt
  return

window.captureEvents Event.KEYPRESS
window.onkeydown = pressed