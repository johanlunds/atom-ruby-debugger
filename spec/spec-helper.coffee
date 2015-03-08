{spawn} = require 'child_process'

module.exports =
  # returns child process
  startDebuggerProcess: (file, cb) ->
    process = spawn("rdebug-ide", ["--", file])
    process.stderr.on 'data', (data) ->
      if data.toString().match(/Fast Debugger.+listens on.+/)
        cb()
    # process.stdout.on 'data', (data) ->
    # process.on 'exit', (code, signal) ->
    # process.on 'error', (err) ->
    process
