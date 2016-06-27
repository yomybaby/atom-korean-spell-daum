{CompositeDisposable,BufferedProcess} = require 'atom'
WebView = require './webview'
url = require 'url'
path = require 'path'

module.exports = Tishadow =
  tishadowView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command
    @subscriptions.add atom.commands.add 'atom-workspace', 'korean-spellchekcer-daum:check': => @openWebViewPane()
    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        # return
      return unless protocol is 'daumspell:'

      # try
      #   pathname = decodeURI(pathname) if pathname
      # catch error
      #   return
      #   
      #   
      if editor = atom.workspace.getActiveTextEditor()
        snippet = editor.getSelectedText() || editor.getText()
        new WebView fpath: path.join( __dirname, '..', 'postText.html'), protocol: 'file', text: snippet, editor: editor

  deactivate: ->
    @subscriptions.dispose()

  openWebViewPane: ->
    console.log __dirname
    if editor = atom.workspace.getActiveTextEditor()
      snippet = JSON.stringify(editor.getSelectedText() || editor.getText())
            
      uri = 'daumspell://thanks for daum' #+atom.workspace.getActiveTextEditor().getPath()
      previousActivePane = atom.workspace.getActivePane()
      atom.workspace.open(uri, searchAllPanes: true).done (view) ->
        # previousActivePane.activate()
