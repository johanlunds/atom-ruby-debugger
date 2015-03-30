Client = require '../lib/client'
DebuggerContext = require '../lib/debugger-context'

describe "Client", ->

  beforeEach ->
    @context = new DebuggerContext()
    @client = new Client(@context)

  describe "::handleCmd", ->
    describe "when frames", ->
      beforeEach ->
        @input =
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
      
      it "calls context with array of frame args", ->
        spyOn(@context, 'updateBacktrace')
        @client.handleCmd(@input)
        expect(@context.updateBacktrace).toHaveBeenCalled()
        expect(@context.updateBacktrace.mostRecentCall.args[0]).toEqual([
          {
            no: "1"
            file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/em/timers.rb"
            line: 54
            current: "true"
          }
          {
            no: "2"
            file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/eventmachine.rb"
            line: 186
          }
        ])
        
    describe "when suspended", ->
      beforeEach ->
        @input =
          suspended:
            attrs:
              file: "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/em/timers.rb"
              line: "55"
              threadId: "1"
              frames: "21"
      
      it "calls context with file, line", ->
        spyOn(@context, 'paused')
        @client.handleCmd(@input)
        expect(@context.paused).toHaveBeenCalled()
        expect(@context.paused.mostRecentCall.args).toEqual([
          "/usr/local/var/rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/eventmachine-1.0.4/lib/em/timers.rb"
          54
        ])