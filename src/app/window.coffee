# This a weirdo file. We don't create a Window class, we just add stuff to
# the DOM window.

fs = require 'fs'
_ = require 'underscore'
$ = require 'jquery'

windowAdditions =
  rootViewParentSelector: 'body'
  rootView: null
  keymap: null

  setUpKeymap: ->
    Keymap = require 'keymap'

    @keymap = new Keymap()
    @keymap.bindDefaultKeys()
    require(keymapPath) for keymapPath in fs.list(require.resolve("keymaps"))

    @_handleKeyEvent = (e) => @keymap.handleKeyEvent(e)
    $(document).on 'keydown', @_handleKeyEvent

  startup: (path) ->
    @attachRootView(path)
    @loadUserConfiguration()
    $(window).on 'close', => @close()
    $(window).on 'beforeunload', => @saveRootViewState()
    $(window).focus()
    atom.windowOpened this

  shutdown: ->
    @rootView.remove()
    $(window).unbind('focus')
    $(window).unbind('blur')
    $(window).off('before')
    atom.windowClosed this

  attachRootView: (pathToOpen) ->
    rootViewState = atom.rootViewStates[$windowNumber]
    @rootView = if rootViewState
      RootView.deserialize(rootViewState)
    else
      new RootView {pathToOpen}
    $(@rootViewParentSelector).append @rootView

  saveRootViewState: ->
    atom.rootViewStates[$windowNumber] = @rootView.serialize()

  loadUserConfiguration: ->
    try
      require atom.userConfigurationPath if fs.exists(atom.userConfigurationPath)
    catch error
      console.error "Failed to load `#{atom.userConfigurationPath}`", error
      @showConsole()

  requireStylesheet: (path) ->
    fullPath = require.resolve(path)
    content = fs.read(fullPath)
    return if $("head style[path='#{fullPath}']").length
    $('head').append "<style path='#{fullPath}'>#{content}</style>"

  showConsole: ->
    $native.showDevTools()

  onerror: ->
    @showConsole()

window[key] = value for key, value of windowAdditions
window.setUpKeymap()

RootView = require 'root-view'

require 'jquery-extensions'
require 'underscore-extensions'

requireStylesheet 'reset.css'
requireStylesheet 'atom.css'
