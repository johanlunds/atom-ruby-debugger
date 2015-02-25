# ruby-debugger package for Atom

[![Build Status](https://travis-ci.org/johanlunds/atom-ruby-debugger.svg?branch=master)](https://travis-ci.org/johanlunds/atom-ruby-debugger)

Provides a small Ruby-debugger in Atom.

*TODO: insert screenshot here*

## Instructions

There's no published Atom-package yet. Stay tuned!

Currently only Ruby 2 is supported. It might work with Ruby 1.9.

1. Install debugger gems with: `gem install ruby-debug-ide debase`
2. Configure settings:
  
```coffee
"ruby-debugger":
  rdebugIdeBinPath: "rdebug-ide" # you can run `which rdebug-ide` to find the path
  scriptToRun: "script/rails server"
```

You can also set `scriptToRun` per project or per file type. See package [Project Manager](https://github.com/danielbrodin/atom-project-manager). Example `projects.cson`:

```coffee
'My Project':
  # ...
  'settings':
    "ruby-debugger.scriptToRun": "bin/rails server"
```


