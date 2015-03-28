rivets = require 'rivets'

module.exports =
class MainComponent
  constructor: ({@context}) ->
  
  toggleConnected: =>
    if @context.isDisconnected() then @context.connect() else @context.disconnect()
  
  toggleConnectedText: =>
    if @context.isDisconnected() then "Connect" else "Disconnect"

rivets.components['rd-main'] =
  template: ->
    fs.readFileSync(require.resolve('../../templates/main.html'), 'utf8')
    
  initialize: (el, data) ->
    new MainComponent(data)