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
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'

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

gulp.task 'concat', ->
  gulp.src ['assets/js/game_object.js', 'assets/js/*.js']
    .pipe concat 'game.js'
    .pipe gulp.dest 'assets'

gulp.task 'uglify', ->
  gulp.src 'assets/game.js'
    .pipe uglify()
    .pipe rename extname: '.min.js'
    .pipe gulp.dest 'assets'

gulp.task 'css', ->
  gulp.src 'css/main.css'
    .pipe plumber()
    .pipe autoprefixer()
    .pipe minifyCSS()
    .pipe gulp.dest 'assets'

gulp.task 'watch', ->
  gulp.watch 'client/*.coffee', ['recompile']
  gulp.watch 'css/main.css', ['css']

gulp.task 'recompile', gulpsync.sync [ ['lint', 'coffee'], 'concat', 'uglify']
gulp.task 'default', ['recompile', 'css', 'watch']
