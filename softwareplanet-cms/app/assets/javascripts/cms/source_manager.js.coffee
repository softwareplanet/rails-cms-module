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
#  $("#file_upload").uploadify
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

  #DELETE SOURCE WITH CONFIRMATION
window.deleteSourceWithConfirmation = (obj) ->
  id_to_delete = $(obj).data("source_id")
  name = $(obj).data("source_name")
  if confirm('Are you sure to delete Layout \'' + name + "\' ?")
    deleteSource('layout', id_to_delete)
    $(obj).parents('.layout-row').next().fadeOut()
    $(obj).parents('.layout-row').fadeOut()
#  $(".icon.icon-structure").click()

 #OPEN CODE EDITOR FOR EDIT LAYOUT CODE
window.show_code_editor = (obj) ->
  $('[data-level=child]').hide();
  request_json =
    object: $(obj).data("source_id")
    activity: "edit"
  $.ajax
    url: "/source_manager/editor.js"
    type: "GET"
    data: request_json

  #DELETE
window.deleteSource = (type, id) ->
  request_json = {}
  request_json["type"] = type
  $.ajax
    url: '/source_manager/' + id + jsformat
    type: "DELETE",
    data: request_json

#window.delete_image = (this_ptr) ->
#  console.log 1
#  if confirm("Are you sure to delete this?")
#    full_name = $(this_ptr).parent().attr('data-full-name')
#    console.log full_name
#    $.post("/source_manager/delete_image.js", {full_name: $(this_ptr).parent().attr('data-full-name')})

window.on_gallery_name_keyup = (event, this_ptr) ->
  if event.keyCode==13
    img_id = $(this_ptr).parent().data('id')
    img_name = $(this_ptr).val()
    $.ajax
      url: "/source_manager/rename_image"
      type: "PUT"
      data: {id: img_id, name: img_name}
    $(this_ptr).blur()



window.properties = (obj) ->
  $(".panel_editor").html ""
  $(obj).parent().find(".preferences").toggle()

window.loadViewer = (obj) ->
  name = $(obj).data('source_name')
  request_json = {
    object: 'panel_viewer',
    activity: 'click',
    layout_name: name
  }
  $.ajax
    url: '/source_manager/panel_components'
    type: 'POST',
    data: request_json


#SLIDE ELEMENT
jQuery.fn.slideLeftShow = (callback) ->
  $width = $(this).outerWidth();
  $(this).css('display','block')
  $(this).css('left', '-' + $width+'px').animate({'left': 0}, 250, 'linear', callback);

jQuery.fn.slideRightShow = (callback) ->
  $width = $(this).outerWidth() + $(window).width()
  $left = $(this).css('left')
  if ($left == 'auto')
    $left = 0
  else
    $left = parseInt($left)
  $(this).css('left', $width + 'px')
  $(this).css('display','block').animate({'left': 0}, 250, 'linear', callback);

jQuery.fn.slideShow = ->
  $(this).css('display','block')

jQuery.fn.slideLeftHide = (callback2) ->
  if($(this).css('display') != 'none')
    $width = $(this).outerWidth()
    callback = ->
      $(this).css('display','none')
      if callback2!=undefined
        callback2()
    $(this).animate({'left': '-' + $width}, 250, 'linear', callback);

jQuery.fn.slideRightHide = (callback) ->
  $width = $(this).outerWidth() + $(window).width()
  callback = ->
    $(this).css('display','none')
  $(this).animate({'left': $width}, 250, 'linear', callback);

jQuery.fn.slideHide = ->
    $(this).css('display','none')




$(document).ready ->
#  $('.layout-row').draggable({revert: "invalid",helper:'clone',cursor: "move"});
#  $('.content').sortable({connectWith: "div"});
#  $(".panel_structure").droppable
#    activeClass: "ui-state-hover"
#    hoverClass: "ui-state-active"
#    drop: (event, ui) ->
##      alert 'finish him!'
#      false