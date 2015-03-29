rivets = require 'rivets'

module.exports =
class MainComponent
  constructor: ({@context}) ->
  
  toggleConnect: =>
    if @context.isDisconnected() then @context.connect() else @context.disconnect()
  
  connectText: =>
    if @context.isDisconnected() then "Connect" else "Disconnect"

  playText: =>
    if @context.isRunning() then "Pause" else "Play"

  togglePlay: =>
    if @context.isRunning() then @context.pause() else @context.play()

rivets.components['rd-main'] =
  template: ->
    fs.readFileSync(require.resolve('../../templates/main.html'), 'utf8')
    
  initialize: (el, data) ->
    new MainComponent(data)