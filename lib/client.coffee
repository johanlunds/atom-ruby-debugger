net = require 'net'
XmlParser = require './xml-parser'

module.exports =
class Client
  constructor: ->
    @host = '127.0.0.1'
    @port = atom.config.get('ruby-debugger.port')
    @client = null
    @server = null
    @cmdParser = new XmlParser()
    @cmdParser.on 'command', (command) => @handleCmd(command)
    
  # TODO: error handling on cmd or socket errors
  connect: ->
    @client = new net.Socket()
    @client.connect @port, @host, ->
      console.log 'Connected'
      return
    @client.on 'data', (data) =>
      console.log 'Received: ' + data
      @cmdParser.write(data.toString())
      return
    @client.on 'close', =>
      console.log 'Connection closed'
      @client = null
      return

  runCmd: (cmd, arg) ->
    if arg
      @client.write(cmd + " " + arg + "\n")
    else
      @client.write(cmd + "\n")

  handleCmd: (command) ->
    # TODO: handle XML-error and unknown XML root-tag
    util = require('util')
    console.log(util.inspect(command, false, null))
    
    name = Object.keys(command)[0]
    
    switch name
      when 'breakpoint'
        file = command.breakpoint.attrs.file
        line = parseInt(command.breakpoint.attrs.line) - 1 # zero-indexed
        atom.workspace.open(file, initialLine: line)
          .then (editor) -> console.log(editor)
      # case 'suspended'           then
      # case 'exception'           then
      # case 'breakpointAdded'     then
      # case 'catchpointSet'       then
      # case 'variables'           then
      # case 'error'               then
      # case 'message'             then
      # case 'eval'                then
      # case 'processingException' then
      # case 'frames'              then
      
      # case 'breakpointDeleted'   then
      # case 'breakpointEnabled'   then
      # case 'breakpointDisabled'  then
      # case 'conditionSet'        then
      # case 'expressions'         then
      # case 'expressionInfo'      then
      # case 'threads'             then
      # case 'breakpoints'         then
      # case 'loadResult'          then

  # Tear down any state and detach
  destroy: ->
    # TODO: stop the debugger when closing project/editor & other events (which?). this method seems to only be run on Atom exit?
    @client?.end()
    @server?.kill() # SIGTERM

