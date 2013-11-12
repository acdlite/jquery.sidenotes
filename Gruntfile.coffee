'use strict'

module.exports = (grunt) ->

  @initConfig

    coffee:
      compile:
        expand: true
        src: '_coffee/*.coffee'
        ext: '.js'
        flatten: true
        dest: 'js'

    compass:
      options:
        sassDir: '_sass'
        cssDir: 'css'
        imagesDir: 'images'
        fontsDir: 'fonts'
        require: ['susy', 'breakpoint']
      build:
        options:
          environment: 'production'

    watch:
      compass:
        files: '_sass/**/*.scss'
        tasks: ['compass']
        options:
          livereload: 1337


  @loadNpmTasks "grunt-contrib-coffee"
  @loadNpmTasks "grunt-contrib-compass"
  @loadNpmTasks "grunt-contrib-watch"

  @registerTask 'build', ['compass', 'coffee']
  
  @registerTask 'default', ['build']