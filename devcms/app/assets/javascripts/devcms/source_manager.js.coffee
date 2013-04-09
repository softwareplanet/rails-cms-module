window.default_layout_source  = "/HAML\n.container-fluid\n  .row-fluid\n    .span2\n    .span8\n      %content:test\n    .span2"
window.default_content_source = "/HAML\n.row-fluid\n  .span12\n    %h2.calign\n      TitleText\n    %p\n      ContentText"

window.defaultPageLayoutSource = default_layout_source
window.defaultPageContentSource = default_layout_source

$(document).ready ->

  # Image Gallery from aloha mode
  $(".changeable-image").click ->
    $("#gallery_popup .gallery-image").parent().parent().show();
    $("#target_image").val($(this).attr('id'))


    if $(this).data('hardsize') == true

      image_width = $(this).attr('width').toString()
      image_height = $(this).attr('height').toString()
      $("#gallery_popup .gallery-image").each (index) ->
        gallery_width = $(this).data('width').toString()
        gallery_height = $(this).data('height').toString()

        if gallery_height != image_height || gallery_width != image_width
          $(this).parent().parent().hide()

    $('#gallery_popup').modal()

  $(".gallery-image").click ->
    on_gallery_image_select(this)

  # Image Gallery upload:
  $("#file_upload").uploadify
    swf: window.uploadify_asset_path #<-from _popups partial
    uploader : '/source_manager/upload.js'
    buttonText  : 'Add image!'
    #scriptData : {"<%= key = Rails.application.config.session_options[:key] %>" :"<%= cookies[key] %>", "<%= request_forgery_protection_token %>" : "<%= form_authenticity_token %>"}
    onUploadStart: (file) ->
      $(".modal-body").animate({scrollTop: $(".gallery-content").height()}, 800)
      $(".gallery-content").append("<div class='img-box spinner'><img src='http://top.rate.ru/images/ajax-loader.gif' class='spinner'></div>")
    onUploadSuccess: (file, data, response) ->
      $.get "/source_manager/upload_success"

  $(".collapse").collapse()

  $('.editor_tab a').click (e) ->
    e.preventDefault()
    $(this).tab('show')

  $(".unloaded").click ->
    return unless $(this).hasClass('unloaded')
    $(this).removeClass("unloaded")
    $(this).parents(".accordion-group").find("textarea").each ->
      editor_name = $(this).attr('id')
      source_id = $(this).data('source_id')
      editorManager.addEditor editor_name, new CodeEditorIDE(editor_name)
      editorManager.getEditor(editor_name).setRequestPath('/source_manager/')
      editorManager.getEditor(editor_name).getRequestSource(source_id)
      editorManager.getEditor(editor_name).setSourceId(source_id)
    true

  window.editorManager = new CodeEditorsManager
  $('TODOtextarea').each ->
    # DEPRECATED -- TOO HUGE LOAD THERE!
    editor_name = $(this).attr('id')
    source_id = $(this).data('source_id')
    editorManager.addEditor editor_name, new CodeEditorIDE(editor_name)
    editorManager.getEditor(editor_name).setRequestPath('/source_manager/')
    editorManager.getEditor(editor_name).getRequestSource(source_id)
    editorManager.getEditor(editor_name).setSourceId(source_id)

  #EDIT
  $('.edit-source').click -> editorManager.getEditor($(this).data('type')).getRequestSource($(this).data('id'))

window.on_gallery_image_select = (this_ptr) ->
  gallery_img_name = $(this_ptr).data('name')
  gallery_img_src = $(this_ptr).attr('src')
  target_img_id = $("#target_image").val()
  $("#" + target_img_id).attr('height', null)
  $("#" + target_img_id).attr('width', null)
  $("#" + target_img_id).attr('src', gallery_img_src)
  $.post("/page_contents/aloha", {content_name:target_img_id, content:gallery_img_src})
  $('#gallery_popup').modal('hide')

window.saveSource = (this_ptr) ->
  console.log(this_ptr)
  $(this_ptr).toggleClass('btn-success')
  $(this_ptr).toggleClass('btn-primary')
  editor_name = $(this_ptr).data("id")
  editor = editorManager.getEditor(editor_name)
  editor.saveSource()

  #DELETE
window.deleteSource = (type, id, name) ->
  if confirm("Are you sure to delete " + type + ' \'' + name + "\' ?")
    request_json = {}
    request_json["type"] = type
    $.ajax
      url: '/source_manager/' + id + jsformat
      type: "DELETE",
      data: request_json
window.delete_image = (this_ptr) ->
  if confirm("Are you sure to delete this?")
    $.post("/source_manager/delete_image.js", {name: $(this_ptr).parent().data('name')})
window.on_gallery_name_keyup = (event, this_ptr) ->
  if event.keyCode==13
    img_id = $(this_ptr).parent().data('id')
    img_name = $(this_ptr).val()
    $.ajax
      url: "/source_manager/rename_image"
      type: "PUT"
      data: {id: img_id, name: img_name}
    $(this_ptr).blur()

$(document).ready ->
  $("#image_src").change ->
    $(this).parent().ajaxSubmit();
    $(this).parent().clearForm();

  $("#load_new_image").click ->
    console.log "click image_src"
    $("#image_src").click()

window.delete_image= (image) ->
  if(confirm("Are you sure to delete?"))
    request_json = name: $(image).data("image-name")
    $.ajax
      url: "/source_manager/delete_image"
      type: "POST"
      data: request_json

window.rename_image = (image) ->
  input = $(image).parent().find("input")
  input.css("display", "block").focus()
  input.val input.parent().find("div[data-image-name]").attr("data-image-name")

window.rename_finish = (image) ->
  request_json =
    id: $(image).parent().attr("id")
    name: $(image).val()
  $.ajax
    url: "/source_manager/rename_image"
    type: "PUT"
    data: request_json
  $(image).css "display", "none"

window.checkKeyForDelete = (image) ->
  if window.event.keyCode == 13
    rename_finish image

window.properties = (obj) ->
  $(".panel_editor").html ""
  console.log 1
  $(obj).parent().find(".preferences").toggle()





