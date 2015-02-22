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
              
    it "handles text nodes and whitespace", ->
      @parser.write("<error>")
      @parser.write("INTERNAL ERROR!!! undefined method `skip&#39; for Debase:Module\n</error>")
      @parser.write(
        [
          "<error>	/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide.rb:53:in `interrupt_last&#39;"
          "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/commands/control.rb:111:in `execute&#39;"
          "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/ide_processor.rb:87:in `block in process_commands&#39;"
          "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/ide_processor.rb:84:in `catch&#39;"
          "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/ide_processor.rb:84:in `process_commands&#39;"
          "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide.rb:124:in `block in start_control&#39;</error>"
        ].join("\t\n")
      )
      
      waitsFor ->
        @res.length == 2

      runs ->
        expect(@res[0]).toEqual
          error:
            text: "INTERNAL ERROR!!! undefined method `skip' for Debase:Module"
            
        expect(@res[1]).toEqual
          error:
            text: [
              "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide.rb:53:in `interrupt_last'"
              "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/commands/control.rb:111:in `execute'"
              "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/ide_processor.rb:87:in `block in process_commands'"
              "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/ide_processor.rb:84:in `catch'"
              "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide/ide_processor.rb:84:in `process_commands'"
              "/usr/local/var/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/ruby-debug-ide-0.4.26/lib/ruby-debug-ide.rb:124:in `block in start_control'"
            ].join("\t\n")
