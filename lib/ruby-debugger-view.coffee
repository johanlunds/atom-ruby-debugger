exec = require('child_process').exec

module.exports =
class RubyDebuggerView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('ruby-debugger')

    # Create message element
    message = document.createElement('button')
    message.textContent = "Run debugger"
    message.addEventListener 'click', => @startDebugger()
    # message.classList.add('message')
    @element.appendChild(message)

  startDebugger: ->
    cmd = "/Users/johan_lunds/.rbenv/versions/2.1.5/bin/ruby -e 'at_exit{sleep(1)};$stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)' /usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.24/bin/rdebug-ide --debug --disable-int-handler --evaluation-timeout 10 --rubymine-protocol-extensions --port 61513 --dispatcher-port 61514 -- /Users/johan_lunds/Documents/Kod/apoex2/script/rails server -b 0.0.0.0 -p 3000 -e development"

    child = exec(cmd)
    child.stdout.on 'data', (data) ->
      console.log 'stdout: ' + data
      return
    child.stderr.on 'data', (data) ->
      console.log 'stdout: ' + data
      return
    child.on 'close', (code) ->
      console.log 'closing code: ' + code
      return


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    # @task.terminate()

  getElement: ->
    @element
