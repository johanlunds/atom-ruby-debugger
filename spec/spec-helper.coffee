{spawn} = require 'child_process'

module.exports =
  # returns child process
  startDebuggerProcess: (file, cb) ->
    process = spawn("rdebug-ide", ["--", file])
    process.stderr.on 'data', (data) ->
      console.debug data.toString()
      if data.toString().match(/Fast Debugger.+listens on.+/)
        cb()
    process.stdout.on 'data', (data) -> console.debug data.toString()
    process.on 'exit', (code, signal) -> console.debug "exit rdebug-ide: #{code} #{signal}"
    process.on 'error', (err) -> console.debug err.toString()
    process
