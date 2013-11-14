{print} = require 'util'
{spawn} = require 'child_process'
async = require 'async'


compile = (callback) ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

watch = ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

minify = (callback) ->
  uglify = spawn 'uglifyjs', ['-o', 'lib/jquery.sidenotes.min.js', 'lib/jquery.sidenotes.js', '-m']
  uglify.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  uglify.stdout.on 'data', (data) ->
    print data.toString()
  uglify.on 'exit', (code) ->
    callback?() if code is 0

build = (callback) ->
  async.series [
    (callback) ->
      compile ->
        callback null
    (callback) -> 
      minify ->
        callback null
  ]

task 'test', 'Run tests', ->
  mocha = spawn 'mocha', ['--compilers', 'coffee:coffee-script', 'test']
  mocha.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  mocha.stdout.on 'data', (data) ->
    print data.toString()

task 'compile', 'Compile lib/ from src/', compile
task 'watch', 'Watch src/ for changes', watch
task 'minify', 'Minify the script after build', minify
task 'build', 'Compile then minify', build