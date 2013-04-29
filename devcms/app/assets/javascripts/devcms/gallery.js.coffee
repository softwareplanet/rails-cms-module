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