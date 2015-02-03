module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      compile: {
        options: {
          join: true,
          bare: true
        },
        files: {
          'snake.js': [
            'coffee/helpers.coffee',
            'coffee/game_object.coffee',
            'coffee/food.coffee',
            'coffee/score.coffee',
            'coffee/speed.coffee',
            'coffee/map.coffee',
            'coffee/snake.coffee',
            'coffee/message.coffee',
            'coffee/game.coffee',
            'coffee/main.coffee'
          ]
        }
      }
    },

    uglify: {
      build: {
        src: 'snake.js',
        dest: 'snake.js'
      }
    },

    watch: {
      scripts: {
        files: ['coffee/*.coffee'],
        tasks: ['coffee'],
        options: {
          spawn: false
        },
      },
    }

  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('default', ['coffee', 'uglify']);
  grunt.registerTask('dev', ['coffee','watch']);
};