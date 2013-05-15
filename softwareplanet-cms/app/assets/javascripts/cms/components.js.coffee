$(document).ready ->
  $('.add-component').click ->
    if $('.panel_new-component').css('display') == 'block'
      $('.panel_new-component').css('display', 'none')
    else
      $("[data-level=child]").hide()
      $(".panel_new-component").css "-webkit-transform", "translate3d(" + $(window).width() + "px, 0, 0)"
      $(".panel_new-component").show()
      setTimeout (->
        $(".panel_new-component").css "-webkit-transform", "translate3d(0, 0, 0)"), 250

  $('.panel_new-component .close-btn').click ->
    $('.panel.panel_new-component').css('display', 'none')

  $('.panel_component_properties .close-btn').click ->
    $('.panel_component_properties').css('display', 'none')

#
# Get component data from component-row
#
window.getComponentData = (obj) ->
  {
  component_id: $(obj).parents('.component-row').attr('data-source_id'),
  component_name: $(obj).parents('.component-row').attr('data-source_name')
  }

window.component_properties = (obj) ->
  component_data = getComponentData(obj)
  request_json = {
    component_id: component_data['component_id'],
    object: 'edit_component',
    activity: 'load'
  }
  $.ajax
    url: '/source_manager/panel_structure'
    type: 'POST',
    data: request_json

#OPEN CODE EDITOR FOR LAYOUT
window.editComponentData = (obj) ->
  $('[data-level=child]').hide()
  component_data = getComponentData(obj)
  showCodeEditor(component_data['component_id'])

window.deleteComponent = (obj) ->
  component_data = getComponentData(obj)
  if confirm('Are you sure to delete component \'' + component_data['component_name'] + "\' ?")
    deleteSource('component', component_data['component_id'])
    component_row = $(obj).parents('.component-row')
    $(component_row).next().fadeOut()
    $(component_row).fadeOut()