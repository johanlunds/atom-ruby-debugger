{EventEmitter} = require 'events'
sax = require 'sax'

module.exports = 
class Parser

  constructor: () ->
    @events = new EventEmitter()
    strict = true
    options = {}
    stack = []
    @parser = sax.parser(strict, options)
    
    @parser.onerror = (e) ->
      # an error happened.
      return

    @parser.onend = ->
      # parser stream is done, and ready to have more stuff written to it.
      return
    
    @parser.ontext = (t) ->
      # got some text.  t is the string of text.
      return

    @parser.onopentag = (node) ->
      # opened a tag.  node has "name" and "attributes"
      stack.push(node)
      return

    @parser.onclosetag = (name) =>
      # closed a tag. "name" is tag name
      node = stack.pop()
      result = {}
      res2 = {}
      res2.attrs = node.attributes if Object.keys(node.attributes).length
      res2.children = node.children if node.children?.length
      result[node.name] = res2
      if stack.length == 0
        @events.emit 'command', result
      else
        parent = stack[stack.length - 1]
        parent.children ?= []
        parent.children.push(result)
      return

  write: (text) ->
    @parser.write(text)
  
  # Supported events:
  #
  # * "command"
  #
  on: (event, cb) ->
    @events.on event, cb
    
    