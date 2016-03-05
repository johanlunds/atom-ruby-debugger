CSON = require 'season'
Client = require '../lib/client'
DebuggerContext = require '../lib/debugger-context'

describe "Client", ->

  beforeEach ->
    @socket = jasmine.createSpyObj('socket', ['write'])
    @client = new Client()
    @client.socket = @socket

  describe '::localVariables', ->
    beforeEach ->
      @response = CSON.readFileSync(require.resolve './fixtures/var_locals.cson')
      @emptyResponse = CSON.readFileSync(require.resolve './fixtures/var_locals_empty.cson')

    it "runs command 'var local'", ->
      @client.localVariables()
      expect(@socket.write).toHaveBeenCalledWith("var local\n")

    it "returns and resolves a Promise to an array of variables", ->
      result = null
      runs ->
        @client.localVariables().then (arg) -> result = arg
        @client.handleCmd(@response)
      waitsFor "resolve", ->
        result
      runs ->
        expect(result).toEqual([
          {
            name: "self"
            kind: "local"
            value: "#<ActiveRecord::ConnectionAdapters::PostgreSQLAdapter:0x007ff2539479e0>"
            type: "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
            hasChildren: true
            compactValue: "#<ActiveRecord::ConnectionAdapters::PostgreSQLAd..."
            objectId: "+0x3ff929ca3cf0"
          }
        ])

    it "handles empty result", ->
      result = null
      runs ->
        @client.localVariables().then (arg) -> result = arg
        @client.handleCmd(@emptyResponse)
      waitsFor "resolve", ->
        result
      runs ->
        expect(result).toEqual([])

    it "can handle multiple async calls in parallel", ->
      promise1 = @client.localVariables()
      promise2 = @client.localVariables()
      @client.handleCmd(@response)
      expect(promise1.inspect().state).toEqual "fulfilled"
      expect(promise2.inspect().state).toEqual "pending"
      @client.handleCmd(@response)
      expect(promise1.inspect().state).toEqual "fulfilled"
      expect(promise2.inspect().state).toEqual "fulfilled"

  describe '::globalVariables', ->
    beforeEach ->
      @response = CSON.readFileSync(require.resolve './fixtures/var_globals.cson')

    it "runs command 'var global'", ->
      @client.globalVariables()
      expect(@socket.write).toHaveBeenCalledWith("var global\n")

    it "returns and resolves a Promise to an array of variables", ->
      result = null
      runs ->
        @client.globalVariables().then (arg) -> result = arg
        @client.handleCmd(@response)
      waitsFor "resolve", ->
        result
      runs ->
        expect(result.length).toBe 82
        expect(result[0]).toEqual
          name: "$!"
          kind: "global"
          hasChildren: false

  describe "::backtrace", ->
    beforeEach ->
      @response =
        frames:
          children: [
            {
              frame:
                attrs:
                  no: "1"
                  file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/em/timers.rb"
                  line: "55"
                  current: "true"
            }
            {
              frame:
                attrs:
                  no: "2"
                  file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/eventmachine.rb"
                  line: "187"
            }
          ]

    it "runs command 'backtrace'", ->
      @client.backtrace()
      expect(@socket.write).toHaveBeenCalledWith("backtrace\n")

    it "returns and resolves a Promise to an array of frames", ->
      result = null
      runs ->
        @client.backtrace().then (arg) -> result = arg
        @client.handleCmd(@response)
      waitsFor "resolve", ->
        result
      runs ->
        expect(result).toEqual([
          {
            no: "1"
            file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/em/timers.rb"
            line: 55
            current: "true"
          }
          {
            no: "2"
            file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/eventmachine.rb"
            line: 187
          }
        ])

  describe "::addBreakpoint", ->
    it "runs command 'breakpoint ./fixtures/simple.rb:1'", ->
      @client.addBreakpoint "./fixtures/simple.rb", "1"
      expect(@socket.write).toHaveBeenCalledWith("break ./fixtures/simple.rb:1\n")

  describe "::handleCmd", ->
    describe "when suspended", ->
      beforeEach ->
        @input =
          suspended:
            attrs:
              file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/em/timers.rb"
              line: "55"
              threadId: "1"
              frames: "21"

      it "emits event 'paused' with breakpoint-argument", ->
        cb = jasmine.createSpy('callback')
        @client.onPaused(cb)
        @client.handleCmd(@input)
        expect(cb).toHaveBeenCalled()
        expect(cb).toHaveBeenCalledWith
          file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/em/timers.rb"
          line: 55
