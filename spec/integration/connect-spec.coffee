{startDebuggerProcess} = require '../spec-helper'

# TODO: add test for backtrace here (need breakpoint add/remove support though)
# TODO: add test for local/global variables
describe "Connecting to rdebug-ide", ->
  
  [workspaceElement, activationPromise, file, process] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('ruby-debugger')
    file = require.resolve('../fixtures/simple.rb')
  
  afterEach ->
    process.kill()
  
  describe "when activating package and connecting to a started instance of rdebug-ide", ->
    it "enables the play button", ->
      
      # 1. start rdebug-ide with Ruby-script
      waitsFor "start of rdebug-ide", (done) ->
        process = startDebuggerProcess(file, done)

      # 2. open the Ruby-file
      waitsForPromise ->
        atom.workspace.open(file)
      
      # 3. activate package
      runs ->
        atom.commands.dispatch workspaceElement, 'ruby-debugger:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # 4. Play/start button should not be active
        expect(workspaceElement.querySelector('.ruby-debugger .play')).toBeDisabled()

        # 5. click on Connect button
        workspaceElement.querySelector('.ruby-debugger .connect').click()

      waitsFor ->
        workspaceElement.querySelector('.ruby-debugger .connect').textContent.trim() == 'Disconnect'

      runs ->
        # 6. Start button should now be active
        expect(workspaceElement.querySelector('.ruby-debugger .play')).not.toBeDisabled()
