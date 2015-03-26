autoprefixer = require 'gulp-autoprefixer'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
concat = require 'gulp-concat'
connect = require 'gulp-connect'
fs = require 'fs'
gulp = require 'gulp'
gulpsync = require('gulp-sync')(gulp)
gutil = require 'gulp-util'
jade = require 'gulp-jade'
livereload = require 'gulp-livereload'
make_barrier = require './coffee/make_barrier'
minifyCSS = require 'gulp-minify-css'
notify = require 'gulp-notify'
open = require 'gulp-open'
plumber = require 'gulp-plumber'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
ftp = require 'gulp-ftp'

game_file = 'game.js'
gulp.task 'set_prod', ->
  game_file = 'game.min.js'

gulp.task 'lint', ->
  gulp.src ['coffee/make_barrier.coffee', 'coffee/front/*.coffee', 'gulpfile.coffee']
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

  gulp.src 'coffee/front/*.coffee'
    .pipe plumber()
    .pipe coffeeStream
    .pipe gulp.dest 'js'

gulp.task 'jade', ->
  lvl = JSON.parse fs.readFileSync './res/lvl_1.json', 'utf-8'
  gulp.src 'jade/index.jade'
    .pipe plumber()
    .pipe jade
      pretty: true
      locals:
        game_file: game_file
        barrier: make_barrier(lvl.barrier) or '[]'
        width: lvl.width or 20
        height: lvl.height or 20
        size: lvl.size or 20
        speed: lvl.speed or 5

    .pipe gulp.dest 'dist'
    .pipe livereload()

gulp.task 'concat', ->
  gulp.src ['js/game_object.js', 'js/*.js']
    .pipe concat 'game.js'
    .pipe gulp.dest 'dist'
    .pipe livereload()

gulp.task 'connect', ->
  connect.server
    root: 'dist'
    port: 4242
    livereload: true

gulp.task 'ftp', ->
  if fs.existsSync './ftp.json'
    ftp_conf = require './ftp.json'
    gulp.src 'dist/*'
      .pipe ftp
        host: ftp_conf.host
        user: ftp_conf.user
        pass: ftp_conf.pass
        remotePath: ftp_conf.path

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
    .pipe plumber()
    .pipe autoprefixer 'last 15 version'
    .pipe minifyCSS()
    .pipe gulp.dest 'dist'
    .pipe livereload()

gulp.task 'watch', ->
  livereload.listen()
  gulp.watch 'coffee/front/*.coffee', ['recompile']
  gulp.watch 'coffee/make_barrier.coffee', ['lint']
  gulp.watch ['jade/*.jade', 'res/*.json'], ['jade']
  gulp.watch 'css/main.css', ['css']

gulp.task 'recompile', gulpsync.sync [ ['lint', 'coffee'], 'concat', 'uglify']
gulp.task 'prod', ['set_prod', 'recompile', 'jade', 'css', 'ftp']
gulp.task 'default', ['recompile', 'css', 'jade', 'connect', 'open', 'watch']
