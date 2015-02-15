# ruby-debugger package

A short description of your package.

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)


# NOTES

* `gem install debugger-xml` which is a compatible replacement for `ruby-debug-ide`
* will install `byebug` or `debugger` automatically
* https://github.com/astashov/debugger-xml
* https://github.com/astashov/vim-ruby-debugger
* https://github.com/ruby-debug/ruby-debug-ide
* XML api docs: see generated PDF in this repo. Source: https://github.com/ruby-debug/ruby-debug-ide/blob/master/doc/protocol-spec.texi
* Trello board: https://trello.com/b/M3yhQM2b
* see pics of Chrome debugger and RubyMine for reference

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
  
```
rdebug-vim --file /Users/johan_lunds/.janus/vim-ruby-debugger/tmp/ruby_debugger --output /Users/johan_lunds/.janus/vim-ruby-debugger/tmp/ruby_debugger_output --socket /var/folders/8s/vjkdryl91yx0m9lvgc1ykhqw0000gn/T/v1MiKsq/2 --logger_file /Users/johan_lunds/.janus/vim-ruby-debugger/tmp/ruby_debugger_log --debug_mode 1 --vim_executable mvim --vim_servername VIM --separator ++vim-ruby-debugger-separator++ -- '/Users/johan_lunds/Documents/Kod/apoex2/script/rails' server
```
  
https://github.com/astashov/vim-ruby-debugger/blob/master/src/ruby_debugger/commands.vim

```
rdebug-ide --debug --disable-int-handler --evaluation-timeout 10 --rubymine-protocol-extensions --port 61513 --dispatcher-port 61514 -- /Users/johan_lunds/Documents/Kod/apoex2/script/rails server -b 0.0.0.0 -p 3000 -e development
```