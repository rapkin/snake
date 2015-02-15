coffee_files = [
  'helpers'
  'game_object'
  'map'
  'food'
  'snake'
  'message'
  'score'
  'speed'
  'game'
  'main'
]

for file, i in coffee_files
  coffee_files[i] = "coffee/#{file}.coffee"

module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)
  require('time-grunt') grunt

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        src: coffee_files
        dest: 'snake.js'
        options:
          join: true
          bare: true

    uglify:
      build:
        src: 'snake.js'
        dest: 'snake.js'

    watch:
      coffee:
        files: '<%= coffee.compile.src %>'
        tasks: ['coffee']
        options:
          livereload: true

    connect:
      default:
        options:
          port: 4242
          hostname: 'localhost'
          keepalive: true

      dev:
        options:
          port: 4242
          hostname: 'localhost'

    open:
      all:
        path: 'http://localhost:<%= connect.default.options.port%>'

    notify_hooks:
      options:
        enabled: true
        max_jshint_notifications: 5
        title: "Snake"
        success: true
        duration: 1

  grunt.registerTask 'default', ['coffee', 'uglify', 'open', 'connect:default']
  grunt.registerTask 'dev', ['connect:dev', 'coffee', 'open', 'watch']
  grunt.task.run 'notify_hooks'
  