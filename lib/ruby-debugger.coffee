View = require './view'
DebuggerContext = require './debugger-context'
{CompositeDisposable} = require 'atom'

module.exports =
class RubyDebugger
  constructor: (state) ->
    @context = new DebuggerContext()
    @view = new View(state.viewState, @context)
    @panel = atom.workspace.addRightPanel(item: @view.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'ruby-debugger:toggle': => @toggle()

  destroy: ->
    @panel.destroy()
    @subscriptions.dispose()
    @view.destroy()
    @context.destroy()

  serialize: ->
    viewState: @view.serialize()

  toggle: ->
    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()
