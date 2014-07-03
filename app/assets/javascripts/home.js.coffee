###
#
# 前端javascript設定
#
#= require jquery
#= require jquery_ujs
#= require jquery.ui.datepicker
#= require jquery.ui.tabs
#= require application
#= require_self

###

$ ->
  not_finish = ($('#booking_form').length > 0)

#  do bind = ->
#    $("#datepicker").datepicker(
#      dateFormat: "yy-mm-dd"
#    ).change ->
#      $.getJSON('/home/get_condition', {booking_day: this.value, id: location.href.split('/').pop()})
#      .done( (response) ->
#          $('#get_info').html $.parseHTML response.attachmentPartial
#          num_of_people = '1'
#          $('#select_people').val(num_of_people)
#          show_zone(num_of_people)
#        )
#      .fail( -> alert 'gg' )

  $(document).on 'click', '.t_select .btn:not(.btn-inverse)', ->
    $('#time').val(this.value)
    $('.t_select .btn').removeClass('checked')
    $(this).addClass('checked')

#  $('#booking_form').submit (e) ->
#    e.preventDefault()
#    $.post("/home/save_booking", $(this).serialize(), 'json')
#    .done( (response) ->
#        if response.success
#          not_finish = false
#          $('#scroll').animate(left: -940)
#        else if response.error
#          alert "訂位失敗，原因：#{response.message}"
#        else
#          alert '原因不明的失敗'
#      )
#    .fail( -> alert '資料傳遞失敗' )
#    false

  $('#to_friend_form').submit (e) ->
    e.preventDefault()
    $.post(this.action, $(this).serialize(), 'json')
    .done( (response) ->
        if response.success
          not_finish = false
          $('#scroll').animate(left: -940 * 3)
        else if response.error
          alert "訂位失敗，原因：#{response.message}"
        else
          alert '原因不明的失敗'
      )
    .fail( -> alert '資料傳遞失敗' )


#  $('#invite_div').submit (e) ->
#
#  if document.getElementById 'wrapper_out'
#    $(document).on 'submit', 'form', (e) ->
#    e.preventDefault()
#    $.post(this.action, $(this).serialize())
#    .done( (response) ->
#        $.fancybox.close();
#        if response.success
#          alert "申請成功，我們會盡快給您邀請碼！"
#        else if response.error
#          alert "#{response.message}"
#        else
#          alert '原因不明的失敗'
#      )
#    .fail( -> alert '資料傳遞失敗' )


  # window.onbeforeunload = -> if not_finish
  #   '您的訂位尚未完成，確定要離開本頁嗎？'

#  $('#pics div').add('#main_pic').click ->
#    $('#lightbox').show().children().attr('src', this.src)

  $('#go_notice').click -> $('#scroll').animate(left: -1880)

  $('.close_window').click ->
    window.opener = null
    window.open(null, '_self', null)
    window.close()
    alert '感謝您的訂位，請關閉此頁面'
    return

  $('#lightbox').click (e) -> $(this).hide() if e.target is this

  $('#my_dingba').click (e) ->
    e.preventDefault()
    if not_finish
      return unless confirm('你的訂位尚未完成，請問要離開這個頁面嗎？')
    window.location.href = '/booker_manage/index';
    return
#    $.get('/booker_manage/my_dingba', {}, 'html')
#    .done( (response) ->
#        $('#main').html response
#      )
#    .fail( -> alert '載入失敗')

  $('#tabs').tabs()

#  $(document).on 'click', '.add_comment', (e) ->
#    e.preventDefault()
#    $('#comment').show().offset($(this).offset()).find(':hidden').val($(this).data('id'))
#
#  $(document).on 'submit', '.#comment form', (e) ->
#    $.post('padding_url', $(this).serialize())
#    .done( -> alert '發訊完成' )
#    .fail( -> alert '發訊失敗' )