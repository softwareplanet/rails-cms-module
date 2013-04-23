# Image Gallery javascript

$(document).ready ->

  # <input file> on change handler
  $("#image_src").change ->
    $(this).parent().ajaxSubmit();
    $(this).parent().clearForm();

  # add image link call <input file> window
  $(".add_image").click ->
    $("#image_src").click()


window.renameOnEnterKey = (image) ->
  if window.event.keyCode == 13
    rename_finish image

window.rename_finish = (image) ->
  request_json =
    id: $(image).parent().attr("id")
    name: $(image).val()
  $.ajax
    url: "/source_manager/rename_image"
    type: "PUT"
    data: request_json
  $(image).css "display", "none"


# image deleting
window.delete_image = (this_ptr) ->
  if confirm('Are you sure to delete this?')
    $.post('/source_manager/delete_image.js', {name: $(this_ptr).parent().data('name')})

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



window.delete_image= (image) ->
  if(confirm("Are you sure to delete?"))
    request_json = name: $(image).data("image-name")
    $.ajax
      url: "/source_manager/delete_image"
      type: "POST"
      data: request_json

window.rename_image = (image) ->
  input = $(image).parent().parent().find("input")
  input.css("display", "block").focus()
  input.val input.parent().find("div[data-image-name]").attr("data-image-name")