{print} = require 'util'
{spawn} = require 'child_process'
async = require 'async'


launch = (command, options = [], callback) ->
  app = spawn command, options
  app.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  app.stdout.on 'data', (data) ->
    print data.toString()
  app.on 'exit', (code) ->
    callback?() if code is 0

compile = (callback) ->
  launch 'coffee', ['-m', '-c', '-o', 'lib', 'src'], (callback or undefined)

watch = ->
  launch 'coffee', ['-w', '-c', '-o', 'lib', 'src']

minify = (callback) ->
  launch 'uglifyjs', ['-o', 'lib/jquery.sidenotes.min.js', 'lib/jquery.sidenotes.js', '-m'], (callback or undefined)

test = (callback) ->
  launch 'mocha', ['--compilers', 'coffee:coffee-script', '--reporter', 'dot', 'test'], (callback or undefined)

build = (callback) ->
  async.series [
    (callback) ->
      compile ->
        callback null
    (callback) -> 
      minify ->
        callback null
    (callback) -> 
      test ->
        callback null
  ]

task 'compile', 'Compile lib/ from src/', compile
task 'watch', 'Watch src/ for changes', watch
task 'minify', 'Minify the script after build', minify
task 'test', 'Run tests', test

task 'build', 'Compile, minify, and run tests', build