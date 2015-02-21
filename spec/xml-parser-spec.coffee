Parser = require '../lib/xml-parser'


describe "XML parsing", ->
  
  beforeEach ->
    @t1 = '<breakpoints><breakpoint n="1" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="18" /><breakpoint n="2" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="35" /><breakpoint n="3" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="18" /><breakpoint n="4" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="35" /></breakpoints>'
    @t2 = '<breakpointAdded no="3" location="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:18"/><breakpointAdded no="4" location="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:35"/>'
    @t3 = '<breakpoint file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="18" threadId="1"/>'
    @t4 = @t1 + @t3

  

  describe "", ->
    it "works for @t1", ->
      parser = new Parser()
      results = []
      parser.on 'command', (res) ->
        results.push(res)
      
      parser.write(@t1)
      
      waitsFor ->
        results.length == 1
      
      runs ->
        expect(results[0]).toEqual
          breakpoints:
            children: [
              breakpoint: 
                attrs:
                  n: "1"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "18"
            ,
              breakpoint:
                attrs:
                  n: "2"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "35"
            ,
              breakpoint:
                attrs:
                  n: "3"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "18"
            ,
              breakpoint:
                attrs:
                  n: "4"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "35"
            ]
      
      
    it "works for @t2", ->
      parser = new Parser()
      results = []
      parser.on 'command', (res) ->
        results.push(res)
      
      parser.write(@t2)
      
      waitsFor ->
        results.length == 2
      
      runs ->
        
        expect(results[0]).toEqual
          breakpointAdded:
            attrs:
              no: "3"
              location: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:18"
        expect(results[1]).toEqual
          breakpointAdded:
            attrs:
              no: "4"
              location: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:35"


    it "works for @t4", ->
      parser = new Parser()
      results = []
      parser.on 'command', (res) ->
        results.push(res)
      
      parser.write(@t4)
      
      waitsFor ->
        results.length == 2
      
      runs ->
        expect(results[0]).toEqual
          breakpoints:
            children: [
              breakpoint:
                attrs:
                  n: "1"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "18"
            ,
              breakpoint:
                attrs:
                  n: "2"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "35"
            ,
              breakpoint:
                attrs:
                  n: "3"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "18"
            ,
              breakpoint:
                attrs:
                  n: "4"
                  file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
                  line: "35"
            ]
        expect(results[1]).toEqual
          breakpoint:
            attrs:
              file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
              line: "18"
              threadId: "1"