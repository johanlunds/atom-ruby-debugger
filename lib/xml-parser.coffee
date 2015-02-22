{EventEmitter} = require 'events'
sax = require 'sax'

# Implement custom streaming XML-parser that
# supports multiple root elements.
module.exports = 
class XmlParser

  constructor: () ->
    @events = new EventEmitter()
    strict = true
    options = { trim: true }
    stack = []
    @parser = sax.parser(strict, options)
    
    @parser.onerror = (e) ->
      # an error happened.
      throw e
      return

    @parser.onend = ->
      # parser stream is done, and ready to have more stuff written to it.
      return
    
    @parser.ontext = (text) ->
      # got some text.  t is the string of text.
      node = stack[stack.length - 1]
      node.text ?= ''
      node.text += text
      return

    @parser.onopentag = (node) ->
      # opened a tag.  node has "name" and "attributes"
      stack.push(node)
      return

    @parser.onclosetag = (name) =>
      # closed a tag. "name" is tag name
      node = stack.pop()
      result = {}
      object = {}
      object.attrs = node.attributes if Object.keys(node.attributes).length
      object.children = node.children if node.children?.length
      object.text = node.text if node.text
      result[node.name] = object
      if stack.length == 1
        @events.emit 'command', result
      else
        parent = stack[stack.length - 1]
        parent.children ?= []
        parent.children.push(result)
      return
    
    # add fake root that is never closed, otherwise the SAX parser will set its internal value
    # 'closedRoot' and throw errors
    @parser.write("<root>")

  write: (text) ->
    @parser.write(text)
  
  # Supported events:
  #
  # * "command"
  #
  on: (event, cb) ->
    @events.on event, cb
    
    