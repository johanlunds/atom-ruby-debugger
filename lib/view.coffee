rivets = require 'rivets'

require './components/main-component'
require './components/variable-tree-component'

module.exports =
class View
  constructor: (serializeState, context) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('ruby-debugger')
    @view = rivets.init('rd-main', @element, {context})

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove?()
    @view.unbind?()

  getElement: ->
    @element
