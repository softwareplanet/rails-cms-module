window.saveCmsProperties = (btn) ->
  images_path = $(".images-path").val()
  default_layout_id = $("#layouts option:selected").attr('id');
  request_json = {
    default_layout_id: default_layout_id
    images_path: images_path
  }
  $.ajax
    url: '/source_manager/update_cms_settings'
    type: 'POST',
    data: request_json