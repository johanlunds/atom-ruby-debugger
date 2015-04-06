q = require 'q'
DebuggerContext = require '../lib/debugger-context'

describe "DebuggerContext", ->

  beforeEach ->
    @context = new DebuggerContext()

  describe '::connect', ->
    it "shows an error message when it fails", ->
      deferred = q.defer()
      spyOn(@context.client, 'connect').andReturn(deferred.promise)
      spyOn(atom.notifications, 'addError')
      @context.connect()
      deferred.reject(new Error("My Error Message"))
      
      waitsFor "resolve", ->
        atom.notifications.addError.calls.length > 0
        
      runs ->
        expect(atom.notifications.addError).toHaveBeenCalledWith("Error: My Error Message", dismissable: true)
        