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
  startDate: new Date
  constructor: (options) ->
    options = {} unless options?
    @activities = options.activities if options.activities?
    @defaultWorkTimes = options.defaultWorkTimes if options.defaultWorkTimes?
  compileActivities: ->
    
  # Calculate the earliest starts for each activity hour wise.
  calculateStarts: ->
    dependentMap = @getDependentMap()
    calculated = {}
    calcStartForActivity = (activity) =>
      latestEnd = 0
      for p in @activities[activity].predecessors
        return false unless calculated[p]?
        latestEnd = Math.max latestEnd, calculated[p] + @activities[p].duration
      calculated[activity] = latestEnd
      calcStartForActivity d for d in dependentMap[activity]
    calcStartForActivity a for a, d of @activities when d.predecessors.length is 0
    calculated
  getDependentMap: ->
    dependentMap = {}
    for n, a of @activities
      dependentMap[n] = [] unless dependentMap[n]?
      if a.predecessors?
        dependentMap[p].push n for p in a.predecessors
    dependentMap
  # Get the date, given a start date and a duration. Takes into account the
  # available hours. Date is an object with day (ISO8601) and hour (start hour
  # of day durationwise)
  getDateAfterDuration: (date, duration) ->
    duration += date.hour if date.hour?
    date = new XDate date.date
    while true
      dateHours = @getAvailableHoursForDate date
      duration -= dateHours
      break if duration <= 0
      date = date.addDays 1
    hour = dateHours + duration
    {
      date: Gantt.dateToIso date
      hour: hour
      ratio: hour / dateHours
    }
  getAvailableHoursForDate: (date) ->
    date = Gantt.dateToIso date if date.getMilliseconds?
    @overriddenWorkTimes[date] ||
    @defaultWorkTimes[Gantt.isoToDate(date).toString('dddd')]
Gantt.dateToIso = (date) -> date.toString 'yyyy-MM-dd'
Gantt.isoToDate = (iso) -> new XDate iso
