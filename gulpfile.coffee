gulp = require 'gulp'
gulpsync = require('gulp-sync')(gulp)
plumber = require 'gulp-plumber'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
notify = require 'gulp-notify'
jade = require 'gulp-jade'
minifyCSS = require 'gulp-minify-css'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
rename = require 'gulp-rename'
livereload = require 'gulp-livereload'
connect = require 'gulp-connect'
gutil = require 'gulp-util'
open = require 'gulp-open'


js_files = [
  'helpers'
  'game_object'
  'map'
  'food'
  'snake'
  'message'
  'score'
  'speed'
  'game'
]
for file, i in js_files
  js_files[i] = "js/#{file}.js"

game_file = 'game.js'
gulp.task 'set_prod', ->
  game_file = 'game.min.js'

gulp.task 'lint', ->
  gulp.src ['coffee/*.coffee', 'gulpfile.coffee']
    .pipe coffeelint()
    .pipe coffeelint.reporter()
    .pipe notify (file) ->
      errors = file.coffeelint.results.length
      'coffeelint ' + file.relative + ' (' + errors + ' errors)\n' if errors > 0

gulp.task 'coffee', ->
  coffeeStream = coffee(bare: true)
    .on 'error', (error) ->
      gutil.beep()
      gutil.log "Coffee compile error: #{error.name} (#{error.message})"

  gulp.src 'coffee/*.coffee'
    .pipe plumber()
    .pipe coffeeStream
    .pipe gulp.dest 'js'

gulp.task 'jade', ->
  gulp.src 'jade/index.jade'
    .pipe jade
      pretty: true,
      locals:
        game_file: game_file
    .pipe gulp.dest 'dist'
    .pipe livereload()

gulp.task 'concat', ->
  gulp.src js_files
    .pipe concat 'game.js'
    .pipe gulp.dest 'dist'
    .pipe livereload()

gulp.task 'connect', ->
  connect.server
    root: 'dist'
    port: 4242
    livereload: true

gulp.task 'open', ->
  gulp.src('dist/index.html')
    .pipe open('', url: 'http://localhost:4242')

gulp.task 'uglify', ->
  gulp.src 'dist/game.js'
    .pipe uglify()
    .pipe rename extname: '.min.js'
    .pipe gulp.dest 'dist'

gulp.task 'css', ->
  gulp.src 'css/main.css'
    .pipe minifyCSS()
    .pipe gulp.dest 'dist'
    .pipe livereload()

gulp.task 'watch', ->
  livereload.listen()
  gulp.watch 'coffee/*.coffee', ['recompile']
  gulp.watch 'jade/*.jade', ['jade']
  gulp.watch 'css/main.css', ['css']

gulp.task 'recompile', gulpsync.sync [ ['lint', 'coffee'], 'concat', 'uglify']
gulp.task 'prod', ['set_prod', 'recompile', 'jade', 'css']
gulp.task 'default', ['recompile', 'css', 'jade', 'connect', 'open', 'watch']
