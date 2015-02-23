View = require './view'
Client = require './client'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    rdebugIdeBinPath:
      type: 'string'
      default: 'rdebug-ide'
    scriptToRun:
      type: 'string'
      default: 'script/rails server'

  activate: (state) ->
    @client = new Client()
    @view = new View(state.viewState, @client)
    @panel = atom.workspace.addBottomPanel(item: @view.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'ruby-debugger:toggle': => @toggle()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @view.destroy()
    @client.destroy()

  serialize: ->
    viewState: @view.serialize()

  toggle: ->
    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()
