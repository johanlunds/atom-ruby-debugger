rivets = require 'rivets'
$ = require 'jquery'

rivets.binders['toggle-panel'] =
  bind: (el) ->
    @callback = =>
      value = @observer.value()
      @observer.setValue(!value)

    $(el).find('.panel-heading').on 'click', @callback

  unbind: (el) ->
    $(el).find('.panel-heading').off 'click', @callback

  routine: (el, value) ->
    $(el)[if value then 'removeClass' else 'addClass']('collapsed')

# the browser doesn't line break file paths very well. take the matter into our own hands :)
rivets.formatters.framePathHtml = (frame) ->
  {file, line} = frame
  parts = file.split("/")
  last = parts.pop()
  parts = parts.map((p) -> p + "/")
  parts.push(last + ":" + line)
  items = parts.map((p) -> "<li>#{p}</li>").join("")
  "<ul>#{items}</ul>"

module.exports =
class MainComponent
  constructor: ({@context}) ->
    # expand/collapse:
    @panels = { watchExprs: true, variables: true, callStack: true, console: true, breakpoints: true }
  
  toggleConnect: =>
    if @context.isDisconnected() then @context.connect() else @context.disconnect()
  
  connectText: =>
    if @context.isDisconnected() then "Connect" else "Disconnect"

  playText: =>
    if @context.isRunning() then "Pause" else "Play"

  togglePlay: =>
    if @context.isRunning() then @context.pause() else @context.play()
  
  playIconClass: =>
    if @context.isRunning() then "rd-icon-pause" else "rd-icon-play"

rivets.components['rd-main'] =
  template: ->
    fs.readFileSync(require.resolve('../../templates/main.html'), 'utf8')
    
  initialize: (el, data) ->
    new MainComponent(data)