###
#
# 全域javascript
#
###
$.fn.live = (event, callback) -> $(document).on event, this.selector, callback

window.validate = (form) ->
  check  = true
  if $(form).attr('id') == 'devise_edit'
    return check

  $(form).find('.invalid').removeClass('invalid')

  $(form).find('input').each ->
    _this = $(this)
    if _this.is('[required]')
      if this.value is ''
        _this.addClass('invalid')
        check = false
    if _this.attr('type') is 'email'
      unless this.value.match(/[\w|.]+@[\w|.]+$/)
        _this.addClass('invalid')
        check = false
    if _this.data('type') is 'date'
      if (new Date(this.value)).toString() == 'Invalid Date'
        _this.addClass('invalid')
        check = false
    if _this.attr('type') is 'url'
      unless this.value.match(/^http(s?):\/\/[\w|.]+$/)
        _this.addClass('invalid')
        check = false
    if _this.attr('type') is 'password'
      unless this.value.length > 6
        _this.addClass('invalid')
        check = false


  $(form).find(':checkbox').each ->
    _this = $(this)
    if _this.is('[required]')
      unless _this.is(':checked')
        _this.addClass('invalid')
        check = false

  $(form).find('select').each ->
    _this = $(this)
    if _this.is('[required]')
      if this.value is ''
        _this.addClass('invalid')
        check = false
  return check


$.datepicker.regional['zh-TW'] = {
  clearText: '清除',
  clearStatus: '清除已選日期',
  closeText: '關閉',
  closeStatus: '取消選擇',
  prevText: '<上一月',
  prevStatus: '顯示上個月',
  nextText: '下一月>',
  nextStatus: '顯示下個月',
  currentText: '今天',
  currentStatus: '顯示本月',
  monthNames: ['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'],
  monthNamesShort: ['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'],
  monthStatus: '選擇月份',
  yearStatus: '選擇年份',
  weekHeader: '周',
  weekStatus: '',
  dayNames: ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'],
  dayNamesShort: ['周日','周一','周二','周三','周四','周五','周六'],
  dayNamesMin: ['日','一','二','三','四','五','六'],
  dayStatus: '設定每周第一天',
  dateStatus: '選擇 m月 d日, DD',
  dateFormat: 'yy-mm-dd',
  firstDay: 1,
  initStatus: '請選擇日期',
  isRTL: false
};

$.datepicker.setDefaults($.datepicker.regional['zh-TW']);



