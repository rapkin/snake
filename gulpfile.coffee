autoprefixer = require 'gulp-autoprefixer'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
concat = require 'gulp-concat'
gulp = require 'gulp'
gulpsync = require('gulp-sync')(gulp)
gutil = require 'gulp-util'
minifyCSS = require 'gulp-minify-css'
notify = require 'gulp-notify'
plumber = require 'gulp-plumber'
uglify = require 'gulp-uglify'
nodemon = require 'gulp-nodemon'
livereload = require 'gulp-livereload'

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
    .pipe uglify()
    .pipe gulp.dest 'assets'

gulp.task 'css', ->
  gulp.src 'css/main.css'
    .pipe plumber()
    .pipe autoprefixer()
    .pipe minifyCSS()
    .pipe gulp.dest 'assets'

gulp.task 'reload', ->
  gulp.src 'server.node.coffee'
    .pipe livereload()

gulp.task 'watch', ->
  livereload.listen()
  nodemon(script: 'server.node.coffee', ext: 'node.coffee')
    .on 'restart', ->
      setTimeout (->
        gulp.src 'server.node.coffee'
          .pipe livereload()
          .pipe notify message: 'SERVER reloaded'
        ), 400

  gulp.watch 'client/*.coffee', gulpsync.sync ['recompile', 'reload']
  gulp.watch 'css/main.css', gulpsync.sync ['css', 'reload']
  gulp.watch 'views/*', ['reload']

gulp.task 'recompile', gulpsync.sync [ ['lint', 'coffee'], 'js']
gulp.task 'default', ['recompile', 'css', 'watch']
