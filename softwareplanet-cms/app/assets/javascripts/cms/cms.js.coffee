#editorManager = null

window.InitializeCms = () ->
  editorManager = new CodeEditorsManager
  editorManager.addEditor "haml_editor", new CodeEditorIDE("haml_editor")
  editorManager.addEditor "css_editor", new CodeEditorIDE("css_editor")
  editorManager.addEditor "head_editor", new CodeEditorIDE("head_editor")
  editorManager.getEditor("haml_editor").code_editor.setOption "mode", "clojure"
  editorManager.getEditor("head_editor").code_editor.setOption "mode", "clojure"
  editorManager.getEditor("css_editor").code_editor.setOption "mode", "css"
  editorManager.getEditor("haml_editor").code_editor.clearHistory()
  editorManager.getEditor("head_editor").code_editor.clearHistory()
  editorManager.getEditor("css_editor").code_editor.clearHistory()

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

  $(".preview-navtab a").click ->
    if $(".preview-content").children().size() is 0
      layout_name = "ru/" + $(".preview-navtab a").data("preview") + "?admin=false"
      $(".preview-content").append "<iframe src=" + layout_name + " width='100%' height='100%'/> "
    else
      layout_name = "ru/" + $(".preview-navtab a").data("preview") + "?admin=false"
      $(".preview-content").html("")
      $(".preview-content").append "<iframe src=" + layout_name + " width='100%' height='100%' style=''/> "


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


  $("body").click ->

#  $('.edit').click  ->
#
#    $.get({
#      url: "/source_manager/menu_bar",
#      data: request_json
#    })
#    $(".layout-row").removeClass "layout-row-selected"
#    $(this).parents(".layout-row").addClass "layout-row-selected"
#    $(".menu-bar").addClass "menu-bar-inactive"
#    source_id = $(this).data("source_id")
#    source_name = $(this).data("source_name")
#    $(".editor-panel .title").html source_name
#    editorManager.getEditor("haml_editor").setRequestPath "/source_manager/"
#    editorManager.getEditor("haml_editor").getRequestSource source_id
#    editorManager.getEditor("haml_editor").setSourceId source_id
#    $(".preview-navtab a").attr "data-preview", source_name
#    css_id = $(this).data("css_id")
#    editorManager.getEditor("css_editor").setRequestPath "/source_manager/"
#    editorManager.getEditor("css_editor").getRequestSource css_id
#    editorManager.getEditor("css_editor").setSourceId css_id
#    $(".editor-panel").show()

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