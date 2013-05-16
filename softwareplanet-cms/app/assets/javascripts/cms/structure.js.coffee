$(document).ready ->
  $('.add-structure').click ->
    if $('.panel_new-page').css('display') == 'block'
      $('.panel_new-page').css('display', 'none')
    else
      $("[data-level=child]").hide()
      $(".panel_new-page").css "-webkit-transform", "translate3d(" + $(window).width() + "px, 0, 0)"
      $(".panel_new-page").show()

      if $(this).hasClass("child-window")
        offset = 280
      else
        offset = 370

      setTimeout (->
        $(".panel_new-page").css "-webkit-transform", "translate3d("+offset+"px, 0, 0)"),
        250

  $('.panel_new-page .close-btn').click ->
    $('.panel.panel_new-page').css('display', 'none')

  $('.panel_properties .close-btn').click ->
    $('.panel_properties').css('display', 'none')

  $('.close-child').click ->
    #$('.panel_child_structure').hide();
    $('.panel_child_structure').css({ translate: [-700,0] })
    $('.panel_structure').removeClass('inactive')
    $(this).css('opacity', 0)
    setTimeout (->
      $('.panel_child_structure').hide()),
      50



#
# Get layout data from layout_row
#
window.getLayoutData = (obj) ->
  {
    source_id: $(obj).parents('.layout-row').attr('data-source_id'),
    source_name: $(obj).parents('.layout-row').attr('data-source_name')
  }

#
# Edit layout properties Click
#
window.editProperties = (obj) ->
  layout_data = getLayoutData(obj)
  request_json = {
  layout_id: layout_data['source_id'],
  object: 'edit_properties',
  activity: 'load'
  }
  $.ajax
    url: '/source_manager/panel_structure'
    type: 'POST',
    data: request_json

#
# Opens code editor
#
window.editLayoutCode = (obj) ->
  layout_data = getLayoutData(obj)
  $('[data-level=child]').hide()
  showCodeEditor(layout_data['source_id'])

#
# Delete layout click
#
window.deleteSourceWithConfirmation = (obj) ->
  layout_data = getLayoutData(obj)
  if confirm('Are you sure to delete layout \'' + layout_data['source_name'] + "\' ?")
    $('[data-level=child]').hide()
    deleteSource('layout', layout_data['source_id'])
    $(obj).parents('.layout-row').next().fadeOut()
    $(obj).parents('.layout-row').fadeOut()

window.openSubPanel = (obj) ->
  $('.panel_new-page').hide()
  $('.clickable_area').parent().removeClass('selected')
  $(obj).parent().addClass('selected');

  layout_data = getLayoutData(obj)
  request_json = {
    layout_id: layout_data['source_id'],
    object: 'structure',
    activity: 'click'
  }
  $.ajax
    url: '/source_manager/panel_structure'
    type: 'POST',
    data: request_json

