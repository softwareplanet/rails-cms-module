$(document).ready ->
  $('.add-structure').click ->
    UI.toggleNewStructurePanel(this)

  $('.panel_new-page .close-btn').click ->
    $('.panel.panel_new-page').css('display', 'none')

  $('.panel_properties .close-btn').click ->
    $('.panel_properties').css('display', 'none')

  $('.close-child').click ->
    UI.hideStructureChildPanel()



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

