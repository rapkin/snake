// Generated by CoffeeScript 1.8.0
var $, log, main_loop_help, pressed, random_int;

log = function(str) {
  return console.log(str);
};

$ = function(id) {
  return document.getElementById(id);
};

random_int = function(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
};

main_loop_help = function() {
  return game.main_loop();
};

pressed = function(e) {
  return game.interupt(e);
};
