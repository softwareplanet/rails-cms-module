window.structure_drag_and_drop = (drag_item, drop_area) ->
  console.log('dropped from:');
  console.log(drop_area);
  console.log('dropped to:');
  console.log(drag_item);
  drag_id = $(drag_item).children().data('source_id')
  drop_id = $(drop_area).children().data('source_id')
  request_json = {
    activity: 'drag_and_drop',
    object: drag_id,
    data: drop_id
  }
  $.ajax
    url: '/source_manager/panel_structure'
    type: 'POST',
    data: request_json