# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $("#prevlink1").click ->
    console.log($('#thumbs .selected').is("#thumbs a:first-child"))
    unless $('#thumbs .selected').is("#thumbs a:first-child")
      index = $('#thumbs .selected').index()
      console.log(index)
      if index > 0
        index = index - 1
        $('#thumbs a')[index].click();
        #$('#thumbs .selected').
        $('#thumbs').trigger('slideTo', [index, 0, true])
    return false

  $("#nextlink1").click ->
    last_index = $('#thumbs a').length-1
    selected_index = $('#thumbs .selected').index()

    #console.log("last_index = " + last_index)
    console.log("selected_index = " + selected_index)

    new_index = selected_index + 1

    #if new_index > last_index
    #  new_index = 0

    #selected_index = $('#thumbs .selected').index()

    unless $('#thumbs a')[new_index].is(':visible')
      new_index = 0

    $('#thumbs a')[new_index].click();
    $('#thumbs').trigger('slideTo', [selected_index, 0, true])
    return false


window.update_header_shadow1 = () ->