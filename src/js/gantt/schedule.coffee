class @GanttSchedule
  defaultWorkTimes:
    Monday: 8
    Tuesday: 8
    Wednesday: 8
    Thursday: 8
    Friday: 8
    Saturday: 0
    Sunday: 0
  overriddenWorkTimes: {}
  # Get the date, given a start date and a duration. Takes into account the
  # available hours. Date is an object with day (ISO8601) and hour (start hour
  # of day durationwise)
  getDateAfterDuration: (date, duration) ->
    duration += date.hour if date.hour?
    d = new XDate date.date
    while true
      dateHours = @getAvailableHoursForDate d
      duration -= dateHours
      break if duration <= 0
      d = d.addDays 1
    hour = dateHours + duration
    new GanttDate
      date: d
      hour: hour
      availableHours: dateHours
  getDateBeforeDuration: (date, duration) ->
    duration -= date.hour if date.hour?
    d = new XDate date.date
    until duration <= 0
      d.addDays -1
      dateHours = @getAvailableHoursForDate d
      duration -= dateHours
    hour = -duration
    new GanttDate
      date: d
      hour: hour
      availableHours: dateHours
  getAvailableHoursForDate: (date) ->
    date = GanttDate.dateToIso date if date.getMilliseconds?
    @overriddenWorkTimes[date] ||
    @defaultWorkTimes[GanttDate.isoToDate(date).toString('dddd')]
  getHoursBetweenDates: (startDate, startHour, endDate, endHour) ->
    hours = endHour - startHour
    curDate = _.clone startDate
    until curDate == endDate
      hours += @getAvailableHoursForDate curDate
      curDate = curDate.addDays 1
    hours