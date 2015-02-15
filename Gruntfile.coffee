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
  require('time-grunt') grunt
  
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        options:
          join: true
          bare: true

        files:
          'snake.js': coffee_files

    uglify:
      build:
        src: 'snake.js'
        dest: 'snake.js'

    watch:
      scripts:
        files: ['coffee/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', ['coffee', 'uglify']
  grunt.registerTask 'dev', ['coffee','watch']
  