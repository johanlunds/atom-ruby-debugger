rivets = require 'rivets'

require './components/main-component.coffee'

module.exports =
class View
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('ruby-debugger')
    @view = rivets.init('rd-main', @element)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove?()
    @view.unbind?()

  getElement: ->
    @element
