net = require 'net'
XmlParser = require './xml-parser'

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

  runCmd: (cmd, arg) ->
    if arg
      @socket.write(cmd + " " + arg + "\n")
    else
      @socket.write(cmd + "\n")

  handleCmd: (command) ->
    util = require('util')
    console.log(util.inspect(command, false, null))
    
    name = Object.keys(command)[0]
    
    switch name
      when 'breakpoint', 'suspended'
        file = command[name].attrs.file
        line = parseInt(command[name].attrs.line) - 1 # zero-indexed
        @context.paused(file, line)

  # Tear down any state and detach
  destroy: ->
    # TODO: stop the debugger when closing project/editor & other events (which?). this method seems to only be run on Atom exit?
    @socket?.end()

