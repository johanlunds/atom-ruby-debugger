RubyDebugger = require './ruby-debugger'

module.exports =
  config:
    rdebugIdeBinPath:
      type: 'string'
      default: 'rdebug-ide'
    scriptToRun:
      type: 'string'
      default: 'script/rails server'

  activate: (state) ->
    @rubyDebugger = new RubyDebugger(state)

  deactivate: ->
    @rubyDebugger.destroy()
    @rubyDebugger = null

  serialize: ->
    @rubyDebugger.serialize()

