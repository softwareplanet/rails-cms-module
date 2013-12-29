window.saveCmsProperties = (btn) ->
  images_path = $(".images-path").val()
  default_layout_id = $("#layouts option:selected").attr('id');
  admin_locale_name = $("#locales option:selected").attr('id');

  if $("#show_locale_in_url")[0].checked
    show_locale_in_url = '1'
  else
    show_locale_in_url = '0'

  request_json = {
    default_layout_id: default_layout_id
    images_path: images_path
    admin_locale_name: admin_locale_name
    show_locale_in_url: show_locale_in_url
  }
  $.ajax
    url: '/source_manager/update_cms_settings'
    type: 'POST',
    data: request_json