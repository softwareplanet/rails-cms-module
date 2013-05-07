# Image Gallery javascript

$(document).ready ->

  # <input file> on change handler
  $("#image_src").change ->
    to_path = $('.panel_gallery .content').attr('data-path')
    console.log to_path
    $('#to_dir').val(to_path)
    console.log $('#to_dir').val()
    $(this).parent().ajaxSubmit()
    $(this).parent().clearForm()

  # add image link call <input file> window
  $(".add_image").click ->
    $("#image_src").click()


window.renameOnEnterKey = (image) ->
  if window.event.keyCode == 13
    rename_finish image

window.renameFolderOnEnterKey = (input) ->
  if window.event.keyCode == 13
    rename_folder_finish input

window.rename_finish = (obj) ->
  image = $(obj).parent()
  old_image_name = $(image).attr('data-name')
  image_path = $(image).attr('data-path')
  new_imame_name = $(obj).val()
  request_json =
    new_name: new_imame_name
    old_name: old_image_name
    path: image_path
  $.ajax
    url: "/source_manager/rename_image"
    type: "PUT"
    data: request_json
  $(obj).css "display", "none"


# image deleting
window.delete_image = (this_ptr) ->
  if confirm('Are you sure to delete this?')
#    console.log $(this_ptr).parent().data('full-name')
    image = $(this_ptr).parent()
    full_image_name = $(image).data('full-name')
    image_path = $(image).data('path')
    $.post('/source_manager/delete_image.js', {full_name: full_image_name, path: image_path})

#
window.on_gallery_name_keyup = (event, this_ptr) ->
  console.log(event.keyCode)
  if event.keyCode==13
    img_id = $(this_ptr).parent().data('id')
    img_name = $(this_ptr).val()
    $.ajax
      url: "/source_manager/rename_image"
      type: "PUT"
      data: {id: img_id, name: img_name}
    $(this_ptr).blur()

window.rename_image = (edit_item) ->
  image = $(edit_item).parent().parent()
  input =  $(image).find("input")
  name = $(image).attr('data-name')
  input.val name
  input.css("display", "block").focus()

$(document).ready ->
  $(".add_folder").click ->
    request_json =
      activity: 'click',
      object: 'add_folder',
      path:  $('.panel_gallery .content').attr('data-path')
    $.ajax
      url: "/source_manager/panel_gallery"
      type: "POST"
      data: request_json

window.open_folder= (obj) ->
  folder = $(obj).parent()
  name = $(folder).attr('data-name')
  path = $(folder).attr('data-path')
  $('.panel_gallery .content').attr('data-path', path + name + '/')
  $('.icon-gallery').click()

window.rename_folder = (edit_icon) ->
  folder = $(edit_icon).parent().parent()
  input = $(folder).find("input")
  input.css("display", "block").focus()
  input.val $(folder).attr("data-name")

window.rename_folder_finish = (input) ->
  folder = $(input).parent()
  path = $(folder).attr('data-path')
  old_name = $(folder).attr('data-name')
  new_name = $(input).val()
  request_json =
    activity: 'click'
    object: 'rename_folder'
    path: path
    new_name: new_name
    old_name: old_name
  console.log request_json
  $.ajax
    url: "/source_manager/panel_gallery"
    type: "POST"
    data: request_json
  $(input).css "display", "none"

window.deleteFolder = (detele_item) ->
  if confirm('Вы уверены что хотите удалить папку и все её содержимое?')
    folder = $(detele_item).parent()
    path = $(folder).attr('data-path')
    name = $(folder).attr('data-name')
    request_json = {
    object: 'delete_folder',
    activity: 'click',
    path: path,
    name: name
    }
    $.ajax
      url: '/source_manager/panel_gallery'
      type: 'POST',
      data: request_json