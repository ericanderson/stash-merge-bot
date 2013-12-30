module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-vows')

  coffee_script_dynamic_files =
    expand: true,
    src: ['src/**/*.coffee']
    dest: 'lib/'
    ext: '.js'

  grunt.initConfig({
    coffee:
      compile:
        options:
          sourceMap: true
        files: [ coffee_script_dynamic_files ]
    coffeelint:
      app:
        files: [ coffee_script_dynamic_files ]
      options:
        no_trailing_whitespace:
          level: 'error'
        line_endings:
          value: 'unix'
          level: 'error'
        max_line_length:
          value: 120
        no_implicit_braces:
          level: 'error'
        no_unnecessary_fat_arrows:
          level: 'error'
    vows:
      all:
        options:
          reporter: 'spec'
          coverage: 'json'
        src: ['test/*.coffee']
  })

  grunt.registerTask 'default', ['coffeelint', 'vows', 'coffee']
  grunt.registerTask 'test', ['coffeelint', 'vows']
  grunt.registerTask 'prepublish', ['coffee']