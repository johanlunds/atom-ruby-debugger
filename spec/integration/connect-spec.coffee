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

  connect = () ->
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

  testPlayButton = (buttonSelector, clickSelectors, waitsFors) ->
    connect()

    runs ->
      # 4. button should not be active
      expect(workspaceElement.querySelector(buttonSelector)).toBeDisabled()

      # 5. click on Connect button
      workspaceElement.querySelector('.ruby-debugger .connect').click()

    waitsFor ->
      workspaceElement.querySelector('.ruby-debugger .connect').textContent.trim() == 'Disconnect'

    runs ->
      # 6. button should now be active
      expect(workspaceElement.querySelector(buttonSelector)).not.toBeDisabled()

  testStepButton = (buttonSelector) ->
    connect()

    runs ->
      expect(workspaceElement.querySelector(buttonSelector)).toBeDisabled()
      workspaceElement.querySelector('.ruby-debugger .connect').click()

    waitsFor ->
      workspaceElement.querySelector('.ruby-debugger .connect').textContent.trim() == 'Disconnect'

    runs ->
      workspaceElement.querySelector('.ruby-debugger .play').click()

    waitsFor ->
      workspaceElement.querySelector('.ruby-debugger .play').title.trim() == "Pause"

    runs ->
      workspaceElement.querySelector('.ruby-debugger .play').click()

    waitsFor ()->
      workspaceElement.querySelector('.ruby-debugger .play').title.trim() == "Play"
    ,""
    ,10000

    runs ->
      expect(workspaceElement.querySelector(buttonSelector)).not.toBeDisabled()

  describe "when activating package and connecting to a started instance of rdebug-ide", ->
    it "enables the play button", ->
      testPlayButton '.ruby-debugger .play'

    it "enables the step-over button on pause", ->
      testStepButton '.ruby-debugger .step-over'

    it "enables the step in button on pause", ->
      testStepButton '.ruby-debugger .step-in'

    it "enables the step-out button on pause", ->
      testStepButton '.ruby-debugger .step-out'
