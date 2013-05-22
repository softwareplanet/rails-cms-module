
# params:
# name - textarea id
window.InitializeEditors = (names, ids, modes) ->
  delete editorManager
  editorManager = new CodeEditorsManager
  editorManager.removeEditors()
  for editor_name, index in names
    editorManager.addEditor(editor_name, new CodeEditorIDE(editor_name))
    editor = editorManager.getEditor(editor_name)
    editor.setMode(modes[index])
    editor.clearHistory()
    editor.setRequestPath("/source_manager/");
    editor.getRequestSource(ids[index]);
    editor.setSourceId(ids[index]);

$(document).ready ->
  $(window).bind "resize", ->
    body_height = $('body').height()
    if body_height > $('.toolbar').css('min-height')
      $('.toolbar').css('height', body_height)

#################################################################################

# Handlers
$(document).ready ->

# do not remove next 5 lines!...or remove...
#  $('.icon').hover (->
#    tooltip_text = $(this).data("tooltip")
#    $(this).append $("<div class='icon-tooltip'><ins></ins>" + tooltip_text + "</div>")
#  ), ->
#    $(this).find('.icon-tooltip').remove()

  $('.icon').click ->
    return if hasUnsavedChanges()
    $('.icon').removeClass("highlighted");
    $(this).addClass("highlighted");
    request_json = {
    object: $(this).data('icon'),
    activity: 'click'
    }

    $.ajax
      url: '/source_manager/tool_bar'
      type: 'GET',
      data: request_json


  $(".css-navtab a").click ->
    # ugly hack to update hidden codemirror window ;(
    setTimeout "editorManager.getEditor('css_editor').code_editor.refresh();", 100

  $(".save-haml-btn").click ->
    editorManager.getEditor("haml_editor").saveSource()

  $(".save-css-btn").click ->
    editorManager.getEditor("css_editor").saveSource()

  $(".haml-tab .languages-dropdown .dropdown-menu a").click ->
    $(".haml-tab .languages-dropdown .dropdown-menu a").removeClass "dropdown-selected"
    $(this).addClass "dropdown-selected"
    language = $(this).data("language")
    editorManager.editors[0].editor.code_editor.setOption "mode", language

  $(".haml-tab .themes-dropdown .dropdown-menu a").click ->
    $(".haml-tab .themes-dropdown .dropdown-menu a").removeClass "dropdown-selected"
    $(this).addClass "dropdown-selected"
    theme = $(this).data("theme")
    editorManager.editors[0].editor.code_editor.setOption "theme", theme

  $(".properties").click ->
    SwitchTo(".page-properties")

# UTIL FUNCTIONS

window.theme_select = (theme, that) ->
  $(".haml-tab .themes-dropdown .dropdown-menu a").removeClass "dropdown-selected"
  $(that).addClass "dropdown-selected"
  editorManager.editors[0].editor.code_editor.setOption "theme", theme
  editorManager.editors[2].editor.code_editor.setOption "theme", theme

window.lang_select = (lang, that) ->
  $(".haml-tab .languages-dropdown .dropdown-menu a").removeClass "dropdown-selected"
  $(that).addClass "dropdown-selected"
  editorManager.editors[0].editor.code_editor.setOption "mode", lang
  editorManager.editors[2].editor.code_editor.setOption "mode", lang

window.SwitchTo = (panel) ->
  $(panel).show()
  $(panel).addClass("active");
  $(".panel1").addClass "menu-bar-inactive"

window.addSpinner = (targetObj) ->
  opts =
    lines: 15     # The number of lines to draw
    length: 5     # The length of each line
    width: 2      # The line thickness
    radius: 14     # The radius of the inner circle
    corners: 1    # Corner roundness (0..1)
    rotate: 0     # The rotation offset
    color: "#fff"   # #rgb or #rrggbb
    speed: 1        # Rounds per second
    trail: 60       # Afterglow percentage
    shadow: false   # Whether to render a shadow
    hwaccel: false  # Whether to use hardware acceleration
    className: "spinner"   # The CSS class to assign to the spinner
    zIndex: 2e9            # The z-index (defaults to 2000000000)
    top: "auto"            # Top position relative to parent in px
    left: "-10px"          # Left position relative to parent in px

  spinner = new Spinner(opts).spin()
  $(targetObj).append(spinner.el)
  #target = document.getElementById(id)
  #target.appendChild(spinner.el)

window.updateCssEditor = () ->
  setTimeout("editorManager.getEditor('css_editor').code_editor.refresh();", 100);

window.codeEditorOnChange = (cm, change, textarea_id) ->
  if change.origin != 'setValue'
    save_btn = $('#'+textarea_id).parents('.tab-pane').find('.save-src-btn')
    $(save_btn).addClass('source-modified')

window.hasUnsavedChanges = () ->
  if $('.source-modified').length > 0
    if confirm("Editors contains unsaved content.\nAre you sure you want to lost your changes?") == false
      return true
  false
