net = require 'net'
_ = require 'underscore-plus'
CSON = require 'season'
q = require 'q'
{EventEmitter} = require 'events'
XmlParser = require './xml-parser'

module.exports =
class Client
  constructor: ->
    @host = '127.0.0.1'
    @port = atom.config.get('ruby-debugger.port') or 1234
    @socket = null
    @events = new EventEmitter()
    @deferreds = []
    @cmdParser = new XmlParser()
    @cmdParser.onCommand (command) => @handleCmd(command)

  onDisconnected: (cb) ->
    @events.on 'disconnected', cb

  onPaused: (cb) ->
    @events.on 'paused', cb

  # Returns Promise
  connect: ->
    deferred = q.defer()
    @socket = net.connect @port, @host
    @socket.on 'connect', =>
      deferred.resolve()
    @socket.on 'error', (e) =>
      deferred.reject(e)
    @socket.on 'data', (data) =>
      console.log 'Received: ' + data
      @cmdParser.write(data.toString())
    @socket.on 'close', =>
      @socket = null
      @events.emit 'disconnected'
    deferred.promise

  # Will trigger event 'disconnected'.
  #
  # Returns null
  disconnect: ->
    @runCmd 'exit'

  # Returns null
  start: ->
    @runCmd 'start'

  # Returns null
  stepIn: ->
    @runCmd 'step'

  stepOut: ->
    @runCmd 'finish'

  stepOver: ->
    @runCmd 'next'

  # Returns null
  continue: ->
    @runCmd 'cont'

  # Will trigger event 'paused'.
  #
  # Returns null
  pause: ->
    @runCmd 'pause'

  # Returns Promise
  backtrace: ->
    @runCmdWithResponse 'backtrace'

  # Returns Promise
  addBreakpoint: (scriptPath, lineNumber) ->
    @runCmdWithResponse 'break', "#{scriptPath}:#{lineNumber}"

  # Returns Promise
  localVariables: ->
    @runCmdWithResponse 'var local'

  # Returns Promise
  globalVariables: ->
    @runCmdWithResponse 'var global'

  runCmd: (cmd, arg) ->
    if arg
      @socket.write(cmd + " " + arg + "\n")
    else
      @socket.write(cmd + "\n")

  runCmdWithResponse: ->
    @deferreds.push deferred = q.defer()
    @runCmd arguments...
    deferred.promise

  # Will resolve a Promise or emit an appropriate event.
  handleCmd: (command) ->
    console.log(CSON.stringify(command))

    name = Object.keys(command)[0]
    data = command[name]
    method = "handle" + _.capitalize(name) + "Cmd"
    @[method]?(data) # ignore not handled cmds

  handleBreakpointAddedCmd: (data) ->
    num = data.attrs.no
    location = data.attrs.location
    @deferreds.shift().resolve(data)
    @events.emit 'breakpointAdded',num,location

  handleBreakpointCmd: (data) ->
    @handleSuspendedCmd(data)

  # response for 'pause'
  handleSuspendedCmd: (data) ->
    file = data.attrs.file
    line = parseInt(data.attrs.line)
    breakpoint = {file, line}
    @events.emit 'paused', breakpoint

  # response for 'backtrace'
  handleFramesCmd: (data) ->
    frames = for entry in data.children
      attrs = entry.frame.attrs
      attrs.line = parseInt(attrs.line)
      attrs
    @deferreds.shift().resolve(frames)

  # response for 'var local', 'var global'
  handleVariablesCmd: (data) ->
    vars = for entry in (data.children or [])
      attrs = entry.variable.attrs
      attrs.hasChildren = attrs.hasChildren is 'true'
      attrs
    @deferreds.shift().resolve(vars)

  # Tear down any state and detach
  destroy: ->
    # TODO: stop the debugger (running "exit") when closing project/editor or toggling debugger panel. this method seems to only be run on Atom exit?
    @events.removeAllListeners()
    @cmdParser.destroy()
    @socket?.end()
