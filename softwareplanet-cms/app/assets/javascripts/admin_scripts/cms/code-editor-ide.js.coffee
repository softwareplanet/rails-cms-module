window.jsformat = '.js'

#  Code editor container - just add editor class and specify it's alias
class window.CodeEditorsManager
  editors: []
  addEditor: (editor_name, editor) ->
    editor =
      editor_name: editor_name
      editor: editor
    @editors.push editor
    editor

  removeEditors: () ->
    while @editors.length > 0
      @editors.pop()

  getEditor: (editor_name) ->
    i = 0
    while i < @editors.length
      return @editors[i]["editor"]  if @editors[i]["editor_name"] is editor_name
      i+=1
    #alert('not found name ' + editor_name)
    return null


class window.CodeEditorIDE
  code_editor : null  # code editor instance, initialized inside the constructor
  source_type : null  # object model type, request parameter
  source_name: null   # source name, request parameter
  source_id : null    # object id, request parameter. "new" value for unsaved sources
  newline_separator : null
  request_path : null
  request_spath : null
  default_template : null
  url : null
  public_page : null
  editable_content : null

  isFullScreen = (cm) ->
    /\bCodeMirror-fullscreen\b/.test cm.getWrapperElement().className
  winHeight = ->
    window.innerHeight or (document.documentElement or document.body).clientHeight
  setFullScreen = (cm, full) ->
    wrap = cm.getWrapperElement()
    if full
      wrap.className += " CodeMirror-fullscreen"
      wrap.style.height = winHeight() + "px"
      document.documentElement.style.overflow = "hidden"
    else
      wrap.className = wrap.className.replace(" CodeMirror-fullscreen", "")
      wrap.style.height = ""
      document.documentElement.style.overflow = ""
    cm.refresh()
  CodeMirror.on window, "resize", ->
    showing = document.body.getElementsByClassName("CodeMirror-fullscreen")[0]
    return  unless showing
    showing.CodeMirror.getWrapperElement().style.height = winHeight() + "px"

  saveEditorsContent = (textarea_name) ->
    $('.save-src-btn').click()
    console.log('all sources were saved!');


  #constructor: (code_textarea_id, newline_separator) ->
  constructor: (code_textarea_id) ->
    code_textarea = document.getElementById (code_textarea_id)
    @code_editor = CodeMirror.fromTextArea(code_textarea,
      continuousScanning: 500,
      lineNumbers: true,

      lineNumbers: true,
      mode: "css",
      theme: "ambiance",
      electricChars: false,
      #autofocus: true
      styleActiveLine: true,
      lineWrapping: true,
      extraKeys:
        F11: (cm) ->
          setFullScreen cm, not isFullScreen(cm)
        "Ctrl-S": (cm) ->
          saveEditorsContent(code_textarea)
          console.log "saved"
        Esc: (cm) ->
          setFullScreen cm, false  if isFullScreen(cm)
    )
    @code_editor.on "change", (cm, change) ->
      codeEditorOnChange(cm, change, code_textarea_id)

    @newline_separator = "\n"
    @source_id = 'new'
  clearHistory: () ->
    @code_editor.clearHistory()
  setMode: (mode_name) ->
    @code_editor.setOption("mode", mode_name)
    this
  setRequestSourceType: (source_type) ->
    @source_type = source_type
  setDefaultTemplate: (default_template) ->
    @default_template = default_template
  # Request attribute
  setSourceId: (id) ->
    @source_id = id
  setValue: (value) ->
    @code_editor.setValue(value)
  getSource: () ->
    @code_editor.getValue()
  getSourceId: () ->
    @source_id
  setUrl: (url) ->
    @url = url
  setPublicPage: (public_page) ->
    @public_page = public_page
  setEditableContent: (editable_content) ->
    @editable_content = editable_content
  getSourceWithSeparator: () ->
    @code_editor.getValue(@newline_separator)

  setSourceWithSeparator: (id, name, source) ->
    this.setValue(source.toString().split(@newline_separator).join("\n"));
    this.setSourceName(name)
    this.setSourceId(id)
  setSourceName: (source_name) ->
    @source_name = source_name
  createSource: () ->
    @source_id = 'new'
    this.setValue(@default_template)
  # specify request urls
  setRequestPath: (request_path) ->
    @request_path = request_path
    @request_spath = request_path.slice(0, -1)
  getRequestSource: (id) ->
    request_json = {}
    request_json['id'] =  id
    $.post('/source_code/edit_source_code/', request_json )

  saveSourceSimple: () ->
    request_json = {}
    request_json["type"] = @source_type
    request_json["url"] = @url
    request_json["public"] = 1
    request_json["model"] = {source: this.getSourceWithSeparator(), name: "test"}
    $.post '/source_code/update_source_code/', request_json

  saveSource: (name) ->
    this.setSourceName(name) unless name is undefined
    request_json = {}
    request_json["id"] = @source_id
    request_json["data"] = this.getSourceWithSeparator()
    $.post '/source_code/update_source_code/', request_json

  deleteSourceHelper: (id) ->
    request_json = {}
    request_json["type"] = @source_type
    $.ajax
      url: @request_path + id + jsformat
      type: "DELETE",
      data: request_json