net = require 'net'
XmlParser = require './xml-parser'
_ = require 'underscore-plus'

module.exports =
class Client
  constructor: (@context) ->
    @host = '127.0.0.1'
    @port = atom.config.get('ruby-debugger.port') or 1234
    @socket = null
    @cmdParser = new XmlParser()
    @cmdParser.onCommand (command) => @handleCmd(command)
    
  connect: ->
    @socket = new net.Socket()
    @socket.connect @port, @host, =>
      @context.connected()
    @socket.on 'data', (data) =>
      console.log 'Received: ' + data
      @cmdParser.write(data.toString())
    @socket.on 'close', =>
      @socket = null
      @context.disconnected()

  disconnect: ->
    @socket?.end()

  start: ->
    @runCmd 'start'

  continue: ->
    @runCmd 'cont'

  pause: ->
    @runCmd 'pause'

  backtrace: ->
    @runCmd 'backtrace'

  runCmd: (cmd, arg) ->
    if arg
      @socket.write(cmd + " " + arg + "\n")
    else
      @socket.write(cmd + "\n")

  handleCmd: (command) ->
    util = require('util')
    console.log(util.inspect(command, false, null))
    
    name = Object.keys(command)[0]
    data = command[name]
    method = "handle" + _.capitalize(name) + "Cmd"
    @[method]?(data) # ignore not handled cmds
  
  handleBreakpointCmd: (data) -> @handleSuspendedCmd(data)
  
  # response for 'pause'
  handleSuspendedCmd: (data) ->
    file = data.attrs.file
    line = parseInt(data.attrs.line) - 1
    @context.paused(file, line)

  # response for 'backtrace'
  handleFramesCmd: (data) ->
    frames = for entry in data.children
      attrs = entry.frame.attrs
      attrs.line = parseInt(attrs.line) - 1
      attrs
    @context.updateBacktrace(frames)

  # Tear down any state and detach
  destroy: ->
    # TODO: stop the debugger when closing project/editor & other events (which?). this method seems to only be run on Atom exit?
    @socket?.end()

