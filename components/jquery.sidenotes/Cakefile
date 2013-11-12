{print} = require 'util'
{spawn, exec} = require 'child_process'

task 'compile', 'Compile lib/ from src/', ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'watch', 'Watch src/ for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'minify', 'Minify the script after build', ->
  exec 'uglifyjs -o lib/jquery.sidenotes.min.js lib/jquery.sidenotes.js -m', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr