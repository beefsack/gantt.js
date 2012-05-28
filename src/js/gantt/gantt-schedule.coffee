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
    date = { date: date } unless _.isObject date
    duration += date.hour if date.hour?
    d = new XDate date.date
    while true
      dateHours = @getAvailableHoursForDate d
      duration -= dateHours
      break if duration <= 0
      d = d.addDays 1
    hour = dateHours + duration
    {
      date: Gantt.dateToIso d
      hour: hour
      ratio: hour / dateHours
    }
  getAvailableHoursForDate: (date) ->
    date = Gantt.dateToIso date if date.getMilliseconds?
    @overriddenWorkTimes[date] ||
    @defaultWorkTimes[Gantt.isoToDate(date).toString('dddd')]
