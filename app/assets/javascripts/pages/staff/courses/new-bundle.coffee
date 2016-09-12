#= require moment.min
#= require fullcalendar.min
#= require locale-all

$ ->
  guid = ->
    s4 = ->
      Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
    s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

  initialLocaleCode = "zh-cn"
  $("#calendar").fullCalendar({
    header:
      left: 'prev,next today'
      center: 'title'
      right: 'month,agendaWeek,agendaDay,listMonth'
    locale: initialLocaleCode
    buttonIcons: true
    weekNumbers: true
    navLinks: true
    editable: true
    eventLimit: true
    fixedWeekCount: false
    nowIndicator: true
    height: 500
    eventClick: (calEvent, jsEvent, view) ->
      $("#calendar").fullCalendar('removeEvents', calEvent.id)
  })

  $(".end-btn").click ->
    course_id = window.cid
    available = $("#available").is(":checked")
    code = $("#course-code").val()
    capacity = $("#course-capacity").val()
    price = $("#course-price").val()
    length = $("#course-length").val()
    date = $("#course-date").val()
    speaker = $("#course-speaker").val()
    address = $("#course-address").val()

    fc_events = $('#calendar').fullCalendar('clientEvents')
    date_in_calendar = []

    $.each(
      fc_events,
      (index, fc_event) ->
        date_in_calendar.push(fc_event.start._i + "," + fc_event.end._i)
    )


    if code == "" || capacity == "" || price == "" || length == "" || date == "" || speaker == "" || address == ""
      $.page_notification("请将信息补充完整")
      return

    $.postJSON(
      '/staff/courses/',
      course: {
        course_id: course_id
        available: available
        code: code
        capacity: capacity
        price: price
        length: length
        date: date
        speaker: speaker
        address: address
        date_in_calendar: date_in_calendar
      },
      (data) ->
        if data.success
          location.href = "/staff/courses/" + data.course_inst_id
        else
          if data.code == COURSE_INST_EXIST
            $.page_notification("课程编号已存在")
          else
            $.page_notification("服务器出错")
      )


  $( "#datepicker" ).datepicker({
        changeMonth: true,
        changeYear: true
      });
  $( "#datepicker" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $('#start-time').timepicker({
    'minTime': '7:00am'
    'maxTime': '9:00pm'
    'showDuration': false
    'timeFormat': 'H:i:s'
  })
  $('#end-time').timepicker({
    'minTime': '7:00am'
    'maxTime': '9:00pm'
    'showDuration': false
    'timeFormat': 'H:i:s'
  })

  $("#add-event").click ->
    date = $("#datepicker").val()
    start_time = $("#start-time").val()
    end_time = $("#end-time").val()
    e = {
      id: guid()
      title: ""
      allDay: false
      start: date + "T" + start_time
      end: date + "T" + end_time
    }
    $("#calendar").fullCalendar('renderEvent', e, true)
