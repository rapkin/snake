log = (str) -> console.log str

$ = (id) -> document.getElementById id

random_int = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min

main_loop_help = ->  do game.main_loop

pressed = (e) -> game.interupt e