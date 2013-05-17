# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.

$(document).ready ->
  $(".localize").click ->
    lang = $(this).data("lang")
    $.get('/user_interfaces/set_locale', {lang: lang})