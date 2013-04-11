$(document).ready ->
  $('.add-structure').click ->
    request_json = {
    object: 'new-page',
    activity: 'click'
    }
    $.ajax
      url: '/source_manager/tool_bar'
      type: 'GET',
      data: request_json
#  $('.btn-save').click ->


  #$(".layout-row").removeClass "layout-row-selected"
  #$(".menu-bar").removeClass "menu-bar-inactive"
  #$(".icon").removeClass "highlighted"
  #$(this).addClass "highlighted"
  #$(".menu-bar").hide()
  #menu_class = $(this).attr("class").split(" ")[1]
  #$(".menu-bar").hide()
  #$(".editor-panel").hide()
  #$(".menu-bar." + menu_class).show()
  #$(".menu-bar." + menu_class).animate
  #  opacity: 1
  #  left: "+=0"
  #  height: "100%"
  #, 0