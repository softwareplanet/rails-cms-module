# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  update_header_shadow()
  $(window).scroll ->
    update_header_shadow()

window.update_header_shadow = () ->
  if $(window).scrollTop() == 0
    $(".navbar-inner").addClass("bottom-shadow-off") unless $(".navbar-inner").hasClass("bottom-shadow-off")
    $(".navbar-inner").removeClass("bottom-shadow-on")
    $(".navbar-inner").addClass("bottom-border-on")
    $("#go-top").stop(true, true).fadeOut("slow");
  else
    $(".navbar-inner").removeClass("bottom-shadow-off")
    $(".navbar-inner").addClass("bottom-shadow-on")
    $(".navbar-inner").removeClass("bottom-border-on")
    if $(window).scrollTop() >= 300
      #$("#go-top").stop(true, true).fadeIn("slow");
      $("#go-top").fadeIn("slow");
    else if $(window).scrollTop() < 300
      #$("#go-top").stop(true, true).fadeOut("slow");
      $("#go-top").fadeOut("slow");