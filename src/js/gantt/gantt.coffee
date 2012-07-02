dateToIso = (date) -> date.toString 'yyyy-MM-dd'
isoToDate = (iso) -> new XDate iso

class @Gantt
  activities: {}
  schedules:
    default: new GanttSchedule
  startDate: dateToIso new XDate
  sort: true
  constructor: (options) ->
    options = {} unless options?
    @activities = options.activities if options.activities?
    @defaultWorkTimes = options.defaultWorkTimes if options.defaultWorkTimes?
  getCompiledActivities: ->
    activityList = []
    activityMap = {}
    # Get calculated information
    starts = @getStarts()
    dependantMap = @getDependantMap()
    # Calculate actual starts and ends
    for n, a of @activities
      sched = @getActivitySchedule a
      a = _.clone a
      a.name = n
      a.startDuration = starts[n]
      a.dependants = dependantMap[n]
      a.startDate = sched.getDateAfterDuration @startDate, a.startDuration
      if a.startDate.hour is @getActivitySchedule(a).getAvailableHoursForDate a.startDate.date
        # Advance to the start of the next day, can't start a task at the end
        xd = Gantt.isoToDate a.startDate.date
        xd = xd.addDays 1
        a.startDate.date = Gantt.dateToIso xd
        a.startDate.hour = 0
      a.endDate = sched.getDateAfterDuration @startDate, a.startDuration + a.duration
      activityList.push a
    # Calculate slack
    for a in activityList
      activityEnd = a.startDuration + a.duration
      if a.dependants.length is 0
        a.slackEndDuration = activityEnd
        a.slackDuration = 0
        a.slackEndDate = a.endDate
        continue
      a.slackEndDuration = null
      for d in a.dependants
        dependantStart = starts[d]
        if not a.slackEndDuration? or dependantStart < a.slackEndDuration
          a.slackEndDuration = dependantStart
          break if a.slackEndDuration is activityEnd
      a.slackDuration = a.slackEndDuration - activityEnd
      sched = @getActivitySchedule a
      a.slackEndDate = sched.getDateAfterDuration @startDate, a.startDuration
    return activityList unless @sort
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
  getActivitySchedule: (a) ->
    if a.scheduleName? then @schedules[a.scheduleName] else @schedules.default 

Gantt.dateToIso = dateToIso
Gantt.isoToDate = isoToDate
