rivets = require 'rivets'

module.exports =
class VariableTree
  constructor: ({@var}) ->
  
rivets.components['rd-variable-tree'] =
  template: ->
    fs.readFileSync(require.resolve('../../templates/variable-tree.html'), 'utf8')
  
  initialize: (el, data) ->
    new VariableTree(data)