# TODO: describe
module.exports =
class Variable
  # TODO: describe
  # * attrs. Object with keys: name, kind, value, type, hasChildren, compactValue, objectId except when root-object
  constructor: (attrs, client) ->
    @[attr] = value for attr, value of attrs
    @children = []
    @client = client
    @isExpanded = false
  
  loadChildren: ->
    @client.instanceVariables(@objectId).then (children) =>
      @children = children
  
  toggleExpanded: =>
    if @hasChildren
      @isExpanded = not @isExpanded
      @loadChildren() if @isExpanded
