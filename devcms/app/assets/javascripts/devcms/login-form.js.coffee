# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.

$(document).ready ->
  $('.login-wrapper button').click (e) ->
    if $('.alert').length > 0
      $('.alert').slideToggle "fast", ->
        $('form').submit()
      e.preventDefault()
    else
      return true

