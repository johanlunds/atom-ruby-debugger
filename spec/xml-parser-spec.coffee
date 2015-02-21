XmlParser = require '../lib/xml-parser'

describe "XmlParser", ->

  beforeEach ->
    @res = []
    @parser = new XmlParser()
    @parser.on 'command', (res) =>
      @res.push(res)

  beforeEach ->
    @t1 = '<breakpoints><breakpoint n="1" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="18" /><breakpoint n="2" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="35" /><breakpoint n="3" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="18" /><breakpoint n="4" file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="35" /></breakpoints>'
    @t2 = '<breakpointAdded no="3" location="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:18"/><breakpointAdded no="4" location="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:35"/>'
    @t3 = '<breakpoint file="/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb" line="18" threadId="1"/>'
    @t4 = @t1 + @t3

  describe "parsing", ->
    it "works for base case", ->
      @parser.write(@t1)
      
      waitsFor ->
        @res.length == 1
      
      runs ->
        expect(@res[0]).toEqual
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
      
    it "works for multiple root elements", ->
      @parser.write(@t2)
      
      waitsFor ->
        @res.length == 2
      
      runs ->
        
        expect(@res[0]).toEqual
          breakpointAdded:
            attrs:
              no: "3"
              location: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:18"
              
        expect(@res[1]).toEqual
          breakpointAdded:
            attrs:
              no: "4"
              location: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb:35"

    it "can have the same element name in both children and root element", ->
      # breakpoint exists both as root element and as child in breakpoints
      @parser.write(@t4)
      
      waitsFor ->
        @res.length == 2
      
      runs ->
        expect(@res[0]).toEqual
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
            
        expect(@res[1]).toEqual
          breakpoint:
            attrs:
              file: "/Users/johan_lunds/Documents/Kod/apoex2/app/controllers/care/authentication_controller.rb"
              line: "18"
              threadId: "1"