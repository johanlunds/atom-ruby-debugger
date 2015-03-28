Client = require './client'

module.exports =
class DebuggerContext
  constructor: ->
    @client = new Client()
  
  destroy: ->
    @client.destroy()