$(document).ready ->
  $('.add-source').click ->
    source_type = $(this).data('type')
    source_name = $(this).parent().find('input.name').val()
    source_url = $(this).parent().find('input.url').val()
    request_json = {}
    #request_json["type"] = source_type

    request_json["model"] = {type: source_type, name: source_name} #, url: source_url
    $.post '/source_manager.js', request_json
    # clear the inputs
    $('.modal').modal('hide')
    $('.modal input').val("")



  #linked source name and url inputs
  $("#layout_popup input.name").keyup ->
    val = $(this).val()
    $("#layout_popup input.url").val(val)


# ----------- MOVE TO GALLERY JS
window.gallery_toggle_list_view = () ->
  $(".img-box").css('float', 'none')
  $(".box").css('float', 'right')
  $(".image-name").css('width', '200px')
  $(".image-name").css('height', '25px')
  $(".tagname-description").css('display', 'inline-block')
  $(".imgsize-description").css('display', 'inline-block')


window.gallery_toggle_compact_view = () ->
  $(".img-box").css('float', 'left')
  $(".box").css('float', 'none')
  $(".box").css('display', 'block')
  $(".image-name").css('width', '80px')
  $(".image-name").css('height', '14px')
  $(".tagname-description").css('display', 'none')
  $(".imgsize-description").css('display', 'none')


