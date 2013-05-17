# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$(document).ready ->
  $('.resume').click ->
    hideNotification()
  $('.send-resume').click ->
    $( "#sendResumeForm").submit()

  $('a[href="#feedbackModal"]').click ->
    $("#feedbackModal").clearForm();
    hideNotification()

  $('a[href="#developmentModal"]').click ->
    $("#developmentModal").clearForm();
    hideNotification()

  $('.add_attach').click ->
    $('#files').click()
  

 

$(document).ready ->
  update_header_shadow()
  $(window).scroll ->
    reposition "header"
    update_header_shadow()

window.update_header_shadow = ->
  if $(window).scrollTop() is 0
    $("#header").addClass "bottom-shadow-off"  unless $("#header").hasClass("bottom-shadow-off")
    $("#header").removeClass "bottom-shadow-on"
    $("#header").addClass "bottom-border-on"
    $("#go-top").stop(true, true).fadeOut "slow"
  else
    $("#header").removeClass "bottom-shadow-off"
    $("#header").addClass "bottom-shadow-on"
    $("#header").removeClass "bottom-border-on"
    if $(window).scrollTop() >= 300
      $("#go-top").fadeIn "slow"
    else $("#go-top").fadeOut "slow"  if $(window).scrollTop() < 300

reposition = (el_id) ->
  el = document.getElementById(el_id)
  ScrollLeft = document.body.scrollLeft
  if ScrollLeft is 0
    if window.pageXOffset
      ScrollLeft = window.pageXOffset
    else
      ScrollLeft = (if (document.body.parentElement) then document.body.parentElement.scrollLeft else 0)
  el.style.left = "-" + ScrollLeft + "px"

next_slide = ->
  slideButtons = $("#sweetcarousel .pagination a")
  current = slideButtons.filter(".current")
  (if current.next().length then current.next().click() else slideButtons.first().click())
prev_slide = ->
  slideButtons = $("#sweetcarousel .pagination a")
  current = slideButtons.filter(".current")
  (if current.prev().length then current.prev().click() else slideButtons.last().click())
$(document).ready ->
  startSlide = 1
  slideBlock = $("#sweetcarousel")
  slideButtons = $("#sweetcarousel .pagination a")
  slideBlock.mouseover(->
    slideBlock.data "over", true
  ).mouseout ->
    slideBlock.data "over", false

  setInterval (->
    if true isnt slideBlock.data("over")
      current = slideButtons.filter(".current")
      (if current.next().length then current.next().click() else slideButtons.first().click())
  ), 995000
  $(".right.carousel-control").click ->
    next_slide()

  $(".left.carousel-control").click ->
    prev_slide()

  $(".pagination a").click (e) ->
    e.preventDefault()
    el = $(this)
    el.parent().find("a").removeClass "current"
    el.addClass "current"
    currentId = "slide_" + el.attr("data-slide")
    $("#sweetcarousel .slide_bg").attr "id", currentId
    $("#sweetcarousel .view").attr "id", currentId
    carouselControlVisible "sliding"
# GoTop

$(document).ready ->
  $("#go-top").click ->
    $("body,html").animate
      scrollTop: 0
    , "slow"



$(document).ready ->
  $(".filter-all").click ->
    $(".team-star").removeClass "hidden"
    $(".our-team-subtitle span").removeClass "selected"
    $(this).addClass "selected"

  $(".filter-dev").click ->
    $(".team-star").addClass "hidden"
    $(".dev").removeClass "hidden"
    $(".our-team-subtitle span").removeClass "selected"
    $(this).addClass "selected"

  $(".filter-mng").click ->
    $(".team-star").addClass "hidden"
    $(".mng").removeClass "hidden"
    $(".our-team-subtitle span").removeClass "selected"
    $(this).addClass "selected"

  $(".filter-qa").click ->
    $(".team-star").addClass "hidden"
    $(".qa").removeClass "hidden"
    $(".our-team-subtitle span").removeClass "selected"
    $(this).addClass "selected"

  $(".filter-design").click ->
    $(".team-star").addClass "hidden"
    $(".design").removeClass "hidden"
    $(".our-team-subtitle span").removeClass "selected"
    $(this).addClass "selected"

#carousel-office

thumb_move = (position_increment) ->
  return  if $("#myCarousel .carousel-inner .item.left, #myCarousel .carousel-inner .item.right").size() > 0
  selected_thumb_index = $("#myThumbCarousel .thumbnail").index($("div.selected-thumb"))
  next_selected_thumb_index = selected_thumb_index + position_increment
  last_thumb_index = $("#myThumbCarousel .thumbnail").index($("#myThumbCarousel .thumbnail").last())
  if next_selected_thumb_index < 0
    next_selected_thumb_index = last_thumb_index
  else next_selected_thumb_index = 0  if next_selected_thumb_index > last_thumb_index
  $(".selected-thumb").removeClass "selected-thumb"
  $($("#myThumbCarousel .thumbnail")[next_selected_thumb_index]).addClass "selected-thumb"
  selected_thumb_ul_index = parseInt(next_selected_thumb_index / 4)
  selected_thumb_li_index = next_selected_thumb_index % 4
  $("#myThumbCarousel").carousel selected_thumb_ul_index
switch_to = (this_ptr) ->
  this_thumb_index = $("#myThumbCarousel .thumbnail").index($(this_ptr))
$(document).ready ->
  $(".autoscroll-off").carousel
    interval: false
    wrap: "circular"

  $("a.right").click ->
    thumb_move +1

  $("a.left").click ->
    thumb_move -1

  $(".thumbnail").click ->
    switch_to this


  $(".thumbnail").click ->
    index = $(".thumbnail").index(this)
    $("#myCarousel").carousel index
    $(".selected-thumb").removeClass "selected-thumb"
    $(this).addClass "selected-thumb"

#fix carousel
$(document).ready ->
  resizeCarousel()
  $(window).bind "resize", ->
    resizeCarousel()

onCarousel = false
$(document).ready ->
  $("#pre2-id-carousel").hover (->
    $('.pos-rel .controls').show()
    onCarousel = true
  ), ->
    onCarousel = false
    carouselControlVisible "resize"

carouselControlVisible = (type) ->
  texts = $('.view .left i img')
  current_number = current_slide()
  if current_number != null
    $('.alternative .project_btn').css('display', 'none')
    $('.alternative .project_btn_' + (current_number + 1)).css('display', 'block')
    current_text = texts[current_number]
    $('.pos-rel .controls').show()
    switch type
      when 'sliding'
        offset = 90
      when 'resize'
        offset = 40
      else
        offset = null
    if (($('.left.carousel-control').offset().left + offset) >=  $("#" + current_text.id).offset().left) && !onCarousel
      $('.pos-rel .controls').hide()

resizeCarousel = ->
  window_size = $(window).width()
  texts = $('.view .left i img')
  buttons = $('.view .left a')
  pictures = $('.view .right i img')
  current_number = 0

  #alt buttons
  if (window_size - 960) > 0
    button_alt_left = (window_size - 960) / 2
  else
    button_alt_left = 0
  $('.alternative a').css('left', button_alt_left)

  #pagination
  if (window_size - 1275) < 0
    $('.pagination').css('left', '0%')
    if window_size > 960
      $('.pagination').css('margin-left', (window_size - 960) / 2 + 288 + 'px')
    else
      $('.pagination').css('margin-left', '288px')
  else
    $('.pagination').css('margin-left', '-125px')
    $('.pagination').css('left', '43%')

  #resize text and image
  while current_number < $('.view .left i').length
    current_text = texts[current_number]
    current_image = pictures[current_number]
    image_width = [711,711,711]
    text_width = [484,560,542]

    current_button = buttons[current_number]
    margin_size = window_size - (text_width[current_number] + image_width[current_number]);
    size_between_images = (window_size - ($('.view .left').width() + image_width[current_number] + margin_size / 3))
    if margin_size > 0
      if $('.view .left').width() >= text_width[current_number]
        $("#" + current_text.id).css('margin-left',  margin_size / 3 + size_between_images * 0.15 + "px")
        $("#" + current_image.id).css('margin-left', size_between_images * 0.85  + "px")
        $("#" + current_button.id).css('margin-left',  margin_size / 3 + size_between_images * 0.15 + "px")
    current_number++
  carouselControlVisible "resize"

current_slide = ->
  slideButtons = $("#sweetcarousel .pagination a")
  if slideButtons.length != 0
    current = slideButtons.filter(".current")
    return current[0].getAttribute('data-slide') - 1
  else return null

$(document).ready ->
  handleFileSelect = (evt) ->
    files = evt.target.files
    output = []
    i = 0
    f = undefined
    while f = files[i]
      file_name = escape(f.name)
      file_name_size = file_name.length
      size = 45
      if file_name.length > size
        text = '...' + file_name.substr(file_name_size - size, file_name_size)
      else
        text = file_name
      output.push "<li>", text, "</li>"
#      output.push "<li><strong>", escape(f.name), "</strong> (", f.type or "n/a", ") - ", f.size, " bytes, last modified: ", f.lastModifiedDate.toLocaleDateString(), "</li>"
      i++
    $("#list").html "<ul>" + output.join("") + "</ul><a class='delete_attach'></a>"
    $(".delete_attach").click ->
      $("#list").html("")
      $("#files").val('')
  if(document.getElementById("files")!=null)
    document.getElementById("files").addEventListener "change", handleFileSelect, false

window.showNotification = (text, type) ->
  $('#notification').removeClass('error')
  $('#notification').removeClass('notice')
  $('.text_notice').css('display','block')
  $('.close_notice').css('display','block')
  $('#notification').addClass(type)
  $('#notification .text_notice').html(text)
  $('#notification').slideDown 300

window.hideNotification = ->
  $('.text_notice').css('display','none')
  $('.close_notice').css('display','none')
  $('#notification').slideUp 300

$(document).ready ->
  $(".close_notice").click ->
    hideNotification()
