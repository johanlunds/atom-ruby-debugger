## NOTES

* `gem install debugger-xml` which is a compatible replacement for `ruby-debug-ide`
* will install `byebug` or `debugger` automatically
* https://github.com/astashov/debugger-xml
* https://github.com/astashov/vim-ruby-debugger
* https://github.com/ruby-debug/ruby-debug-ide
* XML api docs: see generated PDF in this repo. Source: https://github.com/ruby-debug/ruby-debug-ide/blob/master/doc/protocol-spec.texi
* Trello board: https://trello.com/b/M3yhQM2b
* see pics of Chrome debugger and RubyMine for reference
* Moqups: https://moqups.com/#!/edit/johan_lunds/wHo53Ddh (also see exported `.pdf` in docs/)
* https://github.com/mikeric/rivets
  * also read: https://github.com/atom/atom/issues/5756
    * http://vuejs.org/
    * https://github.com/lee-dohm/vue-experiment
    * (https://github.com/atom/elmer)

```
function! RubyDebugger.receive_command() dict
  let file_contents = join(readfile(s:tmp_file), "")
  call s:log("Received command: " . file_contents)
  let commands = split(file_contents, s:separator)
  for cmd in commands
    if !empty(cmd)
      if match(cmd, '<breakpoint ') != -1
        call g:RubyDebugger.commands.jump_to_breakpoint(cmd)
      elseif match(cmd, '<suspended ') != -1
        call g:RubyDebugger.commands.jump_to_breakpoint(cmd)
      elseif match(cmd, '<exception ') != -1
        call g:RubyDebugger.commands.handle_exception(cmd)
      elseif match(cmd, '<breakpointAdded ') != -1
        call g:RubyDebugger.commands.set_breakpoint(cmd)
      elseif match(cmd, '<catchpointSet ') != -1
        call g:RubyDebugger.commands.set_exception(cmd)
      elseif match(cmd, '<variables>') != -1
        call g:RubyDebugger.commands.set_variables(cmd)
      elseif match(cmd, '<error>') != -1
        call g:RubyDebugger.commands.error(cmd)
      elseif match(cmd, '<message>') != -1
        call g:RubyDebugger.commands.message(cmd)
      elseif match(cmd, '<eval ') != -1
        call g:RubyDebugger.commands.eval(cmd)
      elseif match(cmd, '<processingException ') != -1
        call g:RubyDebugger.commands.processing_exception(cmd)
      elseif match(cmd, '<frames>') != -1
        call g:RubyDebugger.commands.trace(cmd)
      endif
    endif
  endfor
  call g:RubyDebugger.queue.after_hook()
  call g:RubyDebugger.queue.execute()
```
  
https://github.com/astashov/vim-ruby-debugger/blob/master/src/ruby_debugger/commands.vim

```
rdebug-ide --debug --disable-int-handler --evaluation-timeout 10 --rubymine-protocol-extensions --port 61513 --dispatcher-port 61514 -- /Users/johan_lunds/Documents/Kod/apoex2/script/rails server -b 0.0.0.0 -p 3000 -e development
```

---

1. add breakpoint ("break file_path:32")
2. remove breakpoint ("delete N" or perhaps "delete" to delete all and then re-add with "break ...")
3. evaluate expressions ("eval ..."). needs to be escaped??? I think ";" is used to separate commands so that needs to be escaped
4. list backtrace ("backtrace") 
5. move up, down and to specified frame ("up", "down", "frame N")
6. show variable values ("var inspect <XYZ>"). what can be sent as <XYZ>??
7. step over, into, out ("step" = into, "next" = over, "finish" = out). "over" and "into" can have arg "+" = force, which is probably useful.
8. continue until next breakpoint ("cont")
9. "var local", "var instance <OBJECT>" where object is object id "+0x123abc" or expression ("Rails.env"?), "var global", "var const <CLASS_OR_MODULE>"

Other: what is "jump" used for??
Other: "thread ..." commands (use together with "backtrace")

Generate Chrome debugger icon font: http://fontastic.me/

```
case 'exception'           then
case 'breakpointAdded'     then
case 'catchpointSet'       then
case 'variables'           then
case 'error'               then
case 'message'             then
case 'eval'                then
case 'processingException' then

case 'breakpointDeleted'   then
case 'breakpointEnabled'   then
case 'breakpointDisabled'  then
case 'conditionSet'        then
case 'expressions'         then
case 'expressionInfo'      then
case 'threads'             then
case 'breakpoints'         then
case 'loadResult'          then
```

TODO: next up:

1. variables: locals, globals. click in tree to expand ("var inspect +0x..." or "var instance +0x..." ???)
2. make panel width resizable (like tree-view does it)
3. backtrace: "frame N" command to go up/down in backtrace
4. add/remove breakpoints (context menu, command panel. extra: click in gutter)
5. step in/out/over
6. indicate breakpoints + frames visually on editor-lines
7. console
8. list breakpoints in panel
9. watch expressions
10. deactivate all breakpoints-button
11. Exception-handling (research!)
12. hover over variables in text editor shows inspect-popover
13. conditional breakpoints
14. CONTINUE TO HERE!

* see Trello board (clean up?)
* write more tests. Integration/feature testing structure!
* breakpoints in gutter: https://gist.github.com/johanlunds/58519a4d630b9724167e

<!-- TODO: use different colors for different types (Array, String, Fixnum, Float, TrueClass, FalseClass, NilClass, Range, Regexp, Symbol, Hash, ... more base-types) -->
<!-- TODO: use different colors for "@inst", "local", "self", "$glob", "@@cvar", "[1]", ... (how does hash keys look?) -->


# TODO: special case: (seems to be when it hasn't been instantiated yet = same as current row)
<variable name="@turd" kind="instance"/>
</variables>

* css
* css: för olika variabeltyper, klasstyper
* css: Globals ska vara dold vid start - hur?
* Variable docs
* tester:
  * funktionstest (visa träd, klicka i underträd)
  * Client: instanceVariables
  * Variable ?


Nice inspiration? https://github.com/Microsoft/vscode-go#debugger