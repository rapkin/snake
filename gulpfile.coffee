autoprefixer  = require 'gulp-autoprefixer'
coffee        = require 'gulp-coffee'
coffeelint    = require 'gulp-coffeelint'
concat        = require 'gulp-concat'
gulp          = require 'gulp'
gulpsync      = require('gulp-sync')(gulp)
gutil         = require 'gulp-util'
livereload    = require 'gulp-livereload'
minifyCSS     = require 'gulp-minify-css'
nodemon       = require 'gulp-nodemon'
notify        = require 'gulp-notify'
plumber       = require 'gulp-plumber'
stylus        = require 'gulp-stylus'

gulp.task 'lint', ->
  gulp.src ['*.coffee', 'client/*.coffee']
    .pipe coffeelint()
    .pipe coffeelint.reporter()
    .pipe notify (file) ->
      errors = file.coffeelint.results.length
      "coffeelint #{file.relative} (#{errors} errors)\n" if errors > 0

gulp.task 'coffee', ->
  coffeeStream = coffee(bare: true)
    .on 'error', (error) ->
      gutil.beep()
      gutil.log "Coffee compile error: #{error.name} (#{error.message})"
  gulp.src 'client/*.coffee'
    .pipe plumber()
    .pipe coffeeStream
    .pipe gulp.dest 'assets/js'

gulp.task 'js', ->
  gulp.src ['assets/js/game_object.js', 'assets/js/*.js']
    .pipe concat 'game.min.js'
    .pipe gulp.dest 'assets'

gulp.task 'stylus', ->
  gulp.src 'stylus/main.styl'
    .pipe plumber()
    .pipe stylus()
    .pipe autoprefixer()
    .pipe gulp.dest 'assets'

gulp.task 'reload', ->
  gulp.src 'server.node.coffee'
    .pipe livereload()

gulp.task 'watch', ->
  livereload.listen()
  gulp.watch 'client/*.coffee', gulpsync.sync ['recompile', 'reload']
  gulp.watch 'stylus/*.styl', gulpsync.sync ['stylus', 'reload']
  gulp.watch 'views/**/*.jade', ['reload']

gulp.task 'start', ->
  nodemon script: 'server.node.coffee', ext: 'node.coffee', tasks: ['lint']
    .on 'restart', ->
      setTimeout (->
        gulp.src 'server.node.coffee'
          .pipe livereload()
          .pipe notify message: 'SERVER reloaded'
        ), 1000

gulp.task 'recompile', gulpsync.sync [ ['lint', 'coffee'], 'js']
gulp.task 'default', ['recompile', 'stylus', 'start', 'watch']
gulp.task 'heroku', ['recompile', 'stylus', 'start']
