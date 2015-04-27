# small utility script to convert XML outputted by Ruby debugger to CSON,
# suitable for saving to a test fixture.

CSON = require 'season'
XmlParser = require '../lib/xml-parser'

cmdParser = new XmlParser()
cmdParser.onCommand (command) -> handleCmd(command)

process.stdin.on 'readable', ->
  chunk = process.stdin.read()
  if chunk != null
    cmdParser.write chunk.toString()

handleCmd = (command) ->
  console.log(CSON.stringify(command))
