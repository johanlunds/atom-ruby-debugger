RubyDebugger = require './ruby-debugger'

module.exports =
  config:
    port:
      type: 'integer'
      default: 1234

  activate: (state) ->
    @rubyDebugger = new RubyDebugger(state)

  deactivate: ->
    @rubyDebugger.destroy()
    @rubyDebugger = null

  serialize: ->
    @rubyDebugger.serialize()

