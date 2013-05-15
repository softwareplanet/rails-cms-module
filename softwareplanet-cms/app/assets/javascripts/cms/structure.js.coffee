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
  component_data = getLayoutData(obj)
  console.log(layout_data['source_id'])
  console.log(layout_data['source_name'])