exec = require('child_process').exec
net = require('net')

module.exports =
class RubyDebuggerView
  constructor: (serializeState) ->
    @client = null
    @child = null
    
    breakpoints = [
      "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:18"
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
    
    ["info break", "start", "exit", "interrupt"].forEach (cmd) =>
      # Create message element
      message = document.createElement('button')
      message.textContent = "Run cmd: " + cmd
      message.addEventListener 'click', => @client.write(cmd + "\n")
      # message.classList.add('message')
      @element.appendChild(message)

    cmd = "break"
    # Create message element
    message = document.createElement('button')
    message.textContent = "Run cmd: " + cmd
    message.addEventListener 'click', =>
      for breakpoint in breakpoints
        @client.write(cmd + " " + breakpoint + "\n")
    # message.classList.add('message')
    @element.appendChild(message)

  startDebugger: ->
    # TODO: fix hardcoded paths here to make it work for any Atom Ruby-project (use Atom scoped settings?)
    cmd = [
      "/Users/johan_lunds/.rbenv/versions/2.1.5/bin/ruby "
      "-e 'at_exit{sleep(1)};$stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)' "
      "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.24/bin/rdebug-ide "
      "--debug "
      "--disable-int-handler "
      "--evaluation-timeout 10 "
      "--rubymine-protocol-extensions "
      "--port 61513 "
      # "--dispatcher-port 61514 "
      "--"
      "/Users/johan_lunds/Documents/Kod/apoex2/script/rails server"
      "-b 0.0.0.0"
      "-p 3000"
      "-e development"
    ].join(" ")



    @child = exec(cmd) # , env: { 'RUBYLIB': '' }
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
      @client.connect 61513, '127.0.0.1', ->
        console.log 'Connected'
        # client.write 'info break'
        return
      @client.on 'data', (data) ->
        console.log 'Received: ' + data
        # client.destroy()
        # kill client after server's response
        return
      @client.on 'close', =>
        console.log 'Connection closed'
        @client = null
        return
    , 5000

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
