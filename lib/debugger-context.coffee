Client = require './client'
StateMachine = require 'javascript-state-machine'

module.exports =
class DebuggerContext
  constructor: ->
    @client = new Client(@)
    @state = StateMachine.create
      initial: 'disconnected'
      events: [
        { name: 'connect',    from: 'disconnected', to: 'connected' }
        { name: 'start',      from: 'connected',    to: 'running' }
        { name: 'pause',      from: 'running',      to: 'paused' }
        { name: 'continue',   from: 'paused',       to: 'running' }
        { name: 'disconnect', from: '*',            to: 'disconnected' }
      ]
  
  connect: =>
    @client.connect()
    
  disconnect: =>
    @client.disconnect()
    
  connected: ->
    @state.connect()
    
  disconnected: ->
    @state.disconnect()
    
  isConnected: =>
    not @isDisconnected()
    
  isDisconnected: =>
    @state.is('disconnected')
  
  isRunning: ->
    @state.is('running')
  
  pause: ->
    @client.pause()

  paused: (file, line) ->
    @state.pause()
    # TODO: request variables, call stack/backtrace etc. open the current file + line
    atom.workspace.open(file, initialLine: line)
      .then (editor) -> console.log(editor)

  play: ->
    if @state.can('start')
      @client.start()
      @state.start()
    else
      @client.continue()
      @state.continue()
    
  destroy: ->
    @client.destroy()