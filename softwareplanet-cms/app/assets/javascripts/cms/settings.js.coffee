window.setDefaultLayout = (id) ->
  request_json = {
    id: id
  }
  $.ajax
    url: '/source_manager/set_default_layout'
    type: 'POST',
    data: request_json

