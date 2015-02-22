RubyDebuggerView = require './ruby-debugger-view'
RubyDebuggerClient = require './ruby-debugger-client'
{CompositeDisposable} = require 'atom'

module.exports = RubyDebugger =
  config:
    rdebugIdeBinPath:
      type: 'string'
      default: 'rdebug-ide'
    scriptToRun:
      type: 'string'
      default: 'script/rails server'

  rubyDebuggerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @client = new RubyDebuggerClient()
    @rubyDebuggerView = new RubyDebuggerView(state.rubyDebuggerViewState, @client)
    @modalPanel = atom.workspace.addBottomPanel(item: @rubyDebuggerView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'ruby-debugger:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @rubyDebuggerView.destroy()
    @client.destroy()

  serialize: ->
    rubyDebuggerViewState: @rubyDebuggerView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
