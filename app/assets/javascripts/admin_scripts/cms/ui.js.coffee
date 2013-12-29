#
# SoftwarePlanet CMS Interface ajax helpers
#
# Table of content:
#
#  Panels management:
#  0. HIDE ALL PANELS                          - UI.hideAllPanels
#  1. HIDE CHILD STRUCTURE PANEL               - UI.hideStructureChildPanel
#  2. TOGGLE VISIBILITY OF NEW STRUCTURE PANEL - UI.toggleNewStructurePanel
#  3. SHOW PANEL BY NAME                       - UI.showPanel ()
#  4. SHOW PANEL SPINNER                       - UI.showPanelSpinner(panel_name)
#  Panel Request object:
#  5. SEND ajax TO GET PANEL DATA              - Request.getPanelData(panel_name, optional_hash)
#  Gallery actions:
#  6. MOVE IMAGE TO ANOTHER FOLDER LOCATION    - GalleryAction.moveImageToFolder(image_id, folder_path)

window.UI =
  #
  # HIDE ALL PANELS
  #
  hideAllPanels: () ->
    @hideStructureChildPanel()
  #
  # HIDE CHILD STRUCTURE PANEL
  #
  hideStructureChildPanel: () ->
    if $('.panel_child_structure:visible').length > 0
      $('.panel_child_structure').css({ translate: [-700,0] })
      $('.panel_structure').removeClass('inactive')
      setTimeout (->
        $('.panel_child_structure').hide()),
      50
    $('.close-child').css 'opacity', 0
    $('.panel_new-page').hide();
    $('.panel_editor').removeClass('subPanelOffset');

  #
  # TOGGLE VISIBILITY OF NEW STRUCTURE PANEL
  #
  toggleNewStructurePanel: (that) ->
    if $('.panel_new-page:visible').length > 0
      $('.panel_new-page').hide()
    else
      $("[data-level=child]").hide()
      $(".panel_new-page").css "-webkit-transform", "translate3d(" + $(window).width() + "px, 0, 0)"
      $(".panel_new-page").css "-moz-transform", "translate3d(" + $(window).width() + "px, 0, 0)"
      $(".panel_new-page").show()

      if $(that).hasClass("child-window")
        $('#new_structure_form #parent_layout').val($('.panel_child_structure').attr('data_parent'));
        offset = 280+90
      else
        offset = 369

      setTimeout (->
        $(".panel_new-page").css "-webkit-transform", "translate3d("+offset+"px, 0, 0)"
        $(".panel_new-page").css "-moz-transform", "translate3d("+offset+"px, 0, 0)"),
      250

  #
  # SHOW PANEL BY NAME
  #
  showPanel: (panel_name) ->
    panel_class = ".panel_" + panel_name
    $(".panel" + "[data-level=\"child\"]").hide()
    if panel_class is ".panel_gallery"
      $(".panel").removeClass "show_panel_level_1"
      setTimeout (->
        $(".panel_gallery").show()
      ), 250
    else
      $(".panel_gallery").hide()
      $(".panel").removeClass "show_panel_level_1"

      $(panel_class).show()
      setTimeout (->
        $(panel_class).addClass "show_panel_level_1"
      ), 250
    $(".panel_editor").html ""
    $(".spinner").remove()
    $(panel_class + " .content").html ""

  #
  # SHOW PANEL SPINNER
  #
  showPanelSpinner: (panel_name) ->
    panel_class = ".panel_" + panel_name
    addSpinner(panel_class + ' .content')


#
# REQUESTS SECTION ##
#
window.Request =
  sendMenuGetRequest: (request_json) ->
    $.ajax
      url: "/source_manager/get_panel_data"
      type: "GET"
      data: request_json

  #
  # SEND REQUEST TO GET PANEL DATA
  # use optional_hash to extend request parameters with new/overrided values
  #
  getPanelData: (panel_name, optional_hash) ->
    @sendMenuGetRequest jQuery.extend(
      object: panel_name
    , optional_hash)

#
# GALLERY actions
#
window.GalleryAction =
  sendGalleryRequest: (request_json, optional_action) ->
    actual_action = "/gallery/user_action"
    if optional_action
      actual_action = ("/gallery/"+optional_action).replace('//', '/')
    $.ajax
      url: actual_action
      type: "POST"
      data: request_json

  #
  # SEND REQUEST TO MOVE IMAGE TO ANOTHER FOLDER
  # folder_path examples: 'newfolder', 'newfolder/subfolder', '/newfolder/subfolder/'
  # use optional_hash to extend request parameters with new/overrided values
  #
  moveImageToFolder: (image_id, folder_path, optional_hash) ->
    @sendGalleryRequest jQuery.extend(
      {
        image_id: image_id,
        folder_path: folder_path
      }
    , optional_hash), 'move_image'