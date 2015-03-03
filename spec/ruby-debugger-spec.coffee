describe "RubyDebugger", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('ruby-debugger')

  describe "when the ruby-debugger:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      expect(workspaceElement.querySelector('.ruby-debugger')).not.toExist()

      atom.commands.dispatch workspaceElement, 'ruby-debugger:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.ruby-debugger')).toExist()

        element = workspaceElement.querySelector('.ruby-debugger')
        expect(element).toExist()

        panel = atom.workspace.panelForItem(element)
        expect(panel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'ruby-debugger:toggle'
        expect(panel.isVisible()).toBe false

    it "hides and shows the view", ->
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.ruby-debugger')).not.toExist()

      atom.commands.dispatch workspaceElement, 'ruby-debugger:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        element = workspaceElement.querySelector('.ruby-debugger')
        expect(element).toBeVisible()
        atom.commands.dispatch workspaceElement, 'ruby-debugger:toggle'
        expect(element).not.toBeVisible()
