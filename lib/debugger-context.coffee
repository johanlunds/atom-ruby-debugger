Client = require './client'
StateMachine = require 'javascript-state-machine'

module.exports =
class DebuggerContext
  constructor: ->
    @client = new Client(@)
    @state = StateMachine.create
      initial: 'disconnected'
      events: [
        { name: 'connected', from: 'disconnected', to: 'connected' }
        { name: 'disconnected', from: 'connected', to: 'disconnected' }
      ]
  
  connect: =>
    @client.connect()
    
  disconnect: =>
    @client.disconnect()
    
  connected: ->
    @state.connected()
    
  disconnected: ->
    @state.disconnected() unless @isDisconnected()
    
  isConnected: =>
    @state.is('connected')
    
  isDisconnected: =>
    @state.is('disconnected')
    
  destroy: ->
    @client.destroy()