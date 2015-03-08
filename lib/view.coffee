rivets = require 'rivets'

module.exports =
class View
  constructor: (serializeState) ->
    template = fs.readFileSync(require.resolve('../templates/ruby-debugger.html'), 'utf8')
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('ruby-debugger')
    @element.innerHTML = template
    @view = rivets.bind(@element)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove?()
    @view.unbind?()

  getElement: ->
    @element
