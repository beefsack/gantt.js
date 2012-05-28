dateToIso = (date) -> date.toString 'yyyy-MM-dd'
isoToDate = (iso) -> new XDate iso

class @Gantt
  activities: {}
  defaultWorkTimes:
    Monday: 8
    Tuesday: 8
    Wednesday: 8
    Thursday: 8
    Friday: 8
    Saturday: 0
    Sunday: 0
  overriddenWorkTimes: {}
  startDate: dateToIso new XDate
  constructor: (options) ->
    options = {} unless options?
    @activities = options.activities if options.activities?
    @defaultWorkTimes = options.defaultWorkTimes if options.defaultWorkTimes?
  getCompiledActivities: ->
    activityList = []
    # Get calculated information
    starts = @getStarts()
    dependantMap = @getDependantMap()
    # Calculate actual starts and ends
    for n, a of @activities
      a = _.clone a
      a.name = n
      a.startDuration = starts[n]
      a.dependants = dependantMap[n]
      a.startDate = @getDateAfterDuration @startDate, a.startDuration
      a.endDate = @getDateAfterDuration @startDate, a.startDuration + a.duration
      activityList.push a
    activityList.sort (a, b) ->
      return 1 if a.startDuration > b.startDuration
      return -1 if b.startDuration > a.startDuration
      return 1 if a.duration > b.duration
      return -1 if b.duration > a.duration
      0
  getActivityList: ->
    list = []
    for n, a of @activities
      newA = _.clone a
      newA.name = n
      list.push newA
    list
  # Calculate the earliest starts for each activity hour wise.
  getStarts: ->
    dependantMap = @getDependantMap()
    calculated = {}
    calcStartForActivity = (activity) =>
      latestEnd = 0
      for p in @activities[activity].predecessors
        return false unless calculated[p]?
        latestEnd = Math.max latestEnd, calculated[p] + @activities[p].duration
      calculated[activity] = latestEnd
      calcStartForActivity d for d in dependantMap[activity]
    calcStartForActivity a for a, d of @activities when d.predecessors.length is 0
    calculated
  getDependantMap: ->
    dependantMap = {}
    for n, a of @activities
      dependantMap[n] = [] unless dependantMap[n]?
      if a.predecessors?
        dependantMap[p].push n for p in a.predecessors
    dependantMap
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

Gantt.dateToIso = dateToIso
Gantt.isoToDate = isoToDate
