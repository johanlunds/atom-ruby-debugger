# ruby-debugger package for Atom

[![Build Status](https://travis-ci.org/johanlunds/atom-ruby-debugger.svg?branch=master)](https://travis-ci.org/johanlunds/atom-ruby-debugger)

Provides a small Ruby-debugger in Atom. **THIS IS CURRENTLY WORK-IN-PROGRESS - IT'S NOT USEFUL YET**.

*TODO: insert screenshot here*

## Instructions

1. Install the package: `apm install ruby-debugger`
2. Install debugger gems with: `gem install ruby-debug-ide debase`
3. Start the debugger with `rdebug-ide -- [SCRIPT] [ARGUMENTS...]`.
   Example: `rdebug-ide -- bin/rails server`.
   It's important that you use **the full path to a Ruby-script**. Otherwise you'll get an error.
4. Connect to the debugger from Atom.

Currently only Ruby 2 is supported. It might work with 1.9 but it hasn't been tested.

### Debugging with `rspec`, `rake` or `bundle`

If you want to start the debugger with `rspec`, `rake`, `bundle` or some other Ruby-binary that you don't know the path to:

* ``rdebug-ide -- `which rspec` spec/lib/foo_spec.rb``
* If you use Rbenv it generates shell wrapper scripts that makes the previous not work. Use `rbenv which` instead of `which`.

## Configuration

If you run `rdebug-ide` with `--port PORT` you can tell Atom which port to connect to:

```coffee
"ruby-debugger":
  port: 1234
```
