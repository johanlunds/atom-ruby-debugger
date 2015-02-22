{exec} = require 'child_process'
net = require 'net'
XmlParser = require './xml-parser'

module.exports =
class RubyDebuggerClient
  constructor: () ->
    @client = null
    @server = null
    @cmdParser = new XmlParser()
    @cmdParser.on 'command', (command) => @handleCmd(command)
    
  # TODO: error handling on cmd or socket errors
  startDebugger: ->
    editor = atom.workspace.getActiveTextEditor()
    scopeDescriptor = editor.getRootScopeDescriptor()
    rdebugIdeBinPath = atom.config.get('ruby-debugger.rdebugIdeBinPath', scope: scopeDescriptor)
    scriptToRun = atom.config.get('ruby-debugger.scriptToRun', scope: scopeDescriptor)
    host = "127.0.0.1"
    port = 61513
    projectDir = atom.project.getPaths()[0]

    cmd = [
      rdebugIdeBinPath
      "--debug"
      "--disable-int-handler"
      "--evaluation-timeout 10"
      # "--rubymine-protocol-extensions"
      "--host #{host}"
      "--port #{port}"
      # "--dispatcher-port 61514"
      "--"
      scriptToRun
    ].join(" ")
    
    console.log("running cmd: ", cmd, " in dir: ", projectDir)

    @server = exec(cmd, cwd: projectDir)
    @server.stdout.on 'data', (data) ->
      console.log 'stdout: ' + data
      return
    @server.stderr.on 'data', (data) ->
      console.log 'stderr: ' + data
      return
    @server.on 'close', (code) =>
      console.log 'closing code: ' + code
      @server = null
      return
    
    setTimeout =>
      @client = new net.Socket()
      @client.connect port, host, ->
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
    , 5000

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

