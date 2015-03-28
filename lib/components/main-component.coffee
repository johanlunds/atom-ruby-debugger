rivets = require 'rivets'

module.exports =
class MainComponent
  constructor: ({@context}) ->

rivets.components['rd-main'] =
  template: ->
    fs.readFileSync(require.resolve('../../templates/main.html'), 'utf8')
    
  initialize: (el, data) ->
    new MainComponent(data)