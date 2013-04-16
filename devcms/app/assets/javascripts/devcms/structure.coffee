$(document).ready ->
  $('.add-structure').click ->
    if $('.panel_new-page').css('display') == 'block'
      $('.panel_new-page').css('display', 'none')
    else
      request_json = {
      object: 'new-page',
      activity: 'click'
      }
      $.ajax
        url: '/source_manager/tool_bar'
        type: 'GET',
        data: request_json

#gear animation
#window.animate_properties = (obj) ->
#
#  if $(obj).hasClass('properties_animate_run')
#    if $(obj).parent().find('.dropdown-menu').css('display') != 'none'
#      $(obj).removeClass('properties_animate_run')
#    else
#      $(obj).removeClass('properties_animate_config')
#      $(obj).removeClass('properties_animate_run')
#
#      $(obj).addClass('properties_animate_config')
#      $(obj).addClass('properties_animate_run')
#
#  else
#    $(obj).addClass('properties_animate_config')
#    $(obj).addClass('properties_animate_run')

#window.qwqw = (panel) ->
#  console.log(panel)
#$menu = $('.dropdown-menu')
#$menu.menuAim({
#  activate: qwqw(1),
#  deactivate: qwqw(2)
#});

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