{View} = require 'atom-space-pen-views'
# {EditorView} = require 'atom'
path = require 'path'

module.exports =
class WebView extends View
  @content: (params) ->
    @div class: 'webview-pane', =>
      @div class: 'webview-buttons-container', =>
        @button class: 'webview-apply', style: 'border-radius: 0; width: 100%; height:44px; color: #fff; font-size:15px; color: #fff; background-color: #028dff; text-shadow: -1px 1px #028dff; border: none;', '교정문 Atom에 바로 적용하기'
      @div class:'webview-container', style: 'height: 100%', =>
        @tag 'webview'

  constructor: ({@fpath, @protocol, @text, @editor}) ->
    super

  getTitle: -> 'Daum 맞춤법 검사기'

  openUri: ->
    uri = @protocol + '://' + @fpath
    unless @webview.src
      @webview.src = uri
      # @webview.openDevTools()
    else
      if uri is @_lastUrib
        @webview.executeJavaScript "location.reload()"
      else
        @webview.executeJavaScript "location.href='#{uri}'"
    @_lastUri = uri
  
  openDaumSpell: ->
    stringifyText = JSON.stringify(@text) 
    @webview.addEventListener 'dom-ready', () ->
      this.executeJavaScript "submit && submit(#{stringifyText})"
      # have to remove 
      this.executeJavaScript '$(".btn_examine").hide()'
    @webview.src = path.join( __dirname, '..', 'postText.html');
  
  applyCorrection: ->
    console.log  'apply'
    # @webview.executeJavaScript '(function(){alert(1)})()'
    # @webview.openDevTools()
    @webview.executeJavaScript '
      var a = jQuery;
      var y = "";
      a.each(a("#resultForm div.cont_spell").children(), function() {
          var z = a(this).prop("tagName");
          if (z === "SPAN") {
              y += a(this).text() + " "
          } else {
              if (z === "BR") {
                  y += "\\n"
              } else {
                  if (z === "A") {
                      y += a(this).data("error-output") + " "
                  }
              }
          }
      });
      
      window.location = "yo://" + encodeURI(y.trim());
      //alert(y.trim());
      //var ipcRenderer = require("electron").ipcRenderer;
      //ipcRenderer.send("query", value);
    '
    
  submitText: ->
      
  canOpenUri: ->
    return true
    
  getPath : -> "daumspell://thanks for daum"

  attached: ->
    webview = @webview = @element.querySelector('webview')
    # webview.nodeintegration = true
    @on 'core:confirm', =>
      @openDaumSpell()
    @on 'click', '.webview-apply', =>
      @applyCorrection()
    @webview.setAttribute("style", "height:100%;");
    @webview.addEventListener 'will-navigate', (e) =>
      # console.log event
      if e.url.startsWith('yo://')
        correctString = e.url.replace('yo://','');
        # editor.setTextInBufferRange()
        console.log e.url
        regEscapedString = @text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
        console.log regEscapedString
        @editor.scan new RegExp(regEscapedString), (it) =>
          it.replace(decodeURI(correctString))
        
        atom.workspace.getActivePane().destroyActiveItem();
        return false
      return true

    @openDaumSpell()
    
  open: ->

  destroy: ->
    @element.remove()


# var w = (function() {
#             var y = "";
#             a.each(a("#resultForm div.cont_spell").children(), function() {
#                 var z = a(this).prop("tagName");
#                 if (z === "SPAN") {
#                     y += a(this).text() + " "
#                 } else {
#                     if (z === "BR") {
#                         y += "\n"
#                     } else {
#                         if (z === "A") {
#                             y += a(this).data("error-output") + " "
#                         }
#                     }
#                 }
#             });
#             return y.trim()
#         })();
