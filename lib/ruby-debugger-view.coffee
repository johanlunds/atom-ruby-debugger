{exec} = require 'child_process'
net = require 'net'
{parseString} = require 'xml2js'

module.exports =
class RubyDebuggerView
  constructor: (serializeState) ->
    @client = null
    @child = null
    
    breakpoints = [
      "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:18"
      "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:35"
    ]
    
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('ruby-debugger')

    # Create message element
    message = document.createElement('button')
    message.textContent = "Start debugger"
    message.addEventListener 'click', => @startDebugger()
    # message.classList.add('message')
    @element.appendChild(message)
    
    ["info break", "start", "exit", "interrupt", "cont"].forEach (cmd) =>
      # Create message element
      message = document.createElement('button')
      message.textContent = "Run cmd: " + cmd
      message.addEventListener 'click', => @runCmd(cmd)
      # message.classList.add('message')
      @element.appendChild(message)

    cmd = "break"
    # Create message element
    message = document.createElement('button')
    message.textContent = "Run cmd: " + cmd
    message.addEventListener 'click', =>
      for breakpoint in breakpoints
        @runCmd(cmd, breakpoint)
    # message.classList.add('message')
    @element.appendChild(message)

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
      "--debug "
      "--disable-int-handler "
      "--evaluation-timeout 10 "
      # "--rubymine-protocol-extensions "
      "--host #{host}"
      "--port #{port}"
      # "--dispatcher-port 61514 "
      "--"
      scriptToRun
    ].join(" ")
    
    console.log("running cmd: ", cmd, " in dir: ", projectDir)

    @child = exec(cmd, cwd: projectDir)
    @child.stdout.on 'data', (data) ->
      console.log 'stdout: ' + data
      return
    @child.stderr.on 'data', (data) ->
      console.log 'stdout: ' + data
      return
    @child.on 'close', (code) =>
      console.log 'closing code: ' + code
      @child = null
      return
    
    setTimeout => 
      @client = new net.Socket()
      @client.connect port, host, ->
        console.log 'Connected'
        # client.write 'info break'
        return
      @client.on 'data', (data) =>
        console.log 'Received: ' + data
        @handleCmd(data)
        # client.destroy()
        # kill client after server's response
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

  handleCmd: (xml) ->
    parseString xml, attrkey: 'attrs', (err, result) ->
      # TODO: handle XML-error and unknown XML root-tag
      util = require('util')
      console.log(util.inspect(result, false, null))
      
      root = Object.keys(result)[0]
      
      switch root
        when 'breakpoint'
          file = result.breakpoint.attrs.file
          line = parseInt(result.breakpoint.attrs.line) - 1 # zero-indexed
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

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    # TODO: stop the debugger when closing project/editor & other events (which?). this method seems to only be run on Atom exit?
    @client?.end()
    @child?.kill() # SIGTERM
    # @child?.kill('SIGHUP')

  getElement: ->
    @element
