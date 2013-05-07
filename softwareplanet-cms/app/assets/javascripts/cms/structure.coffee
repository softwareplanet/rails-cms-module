$(document).ready ->
  $('.add-structure').click ->
    if $('.panel_new-page').css('display') == 'block'
      $('.panel_new-page').css('display', 'none')
    else
      $("[data-level=child]").hide()
      $(".panel_new-page").css "-webkit-transform", "translate3d(" + $(window).width() + "px, 0, 0)"
      $(".panel_new-page").show()
      setTimeout (->
        $(".panel_new-page").css "-webkit-transform", "translate3d(0, 0, 0)"),
        250

  $('.panel_new-page .close-btn').click ->
    $('.panel.panel_new-page').css('display', 'none')

  $('.panel_properties .close-btn').click ->
    $('.panel_properties').css('display', 'none')




#      request_json = {
#      object: 'new-page',
#      activity: 'click'
#      }
#      $.ajax
#        url: '/source_manager/panel_structure'
#        type: 'POST',
#        data: request_json

window.edit_properties = (obj) ->
  console.log 'edit properties click'
  id = $(obj).parent().parent().find('.properties').data('source_id')
  request_json = {
  layout_id: id,
  object: 'edit_properties',
  activity: 'load'
  }
  $.ajax
    url: '/source_manager/panel_structure'
    type: 'POST',
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