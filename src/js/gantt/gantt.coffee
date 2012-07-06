class @Gantt
  activities: {}
  schedules:
    default: new GanttSchedule
  startDate: new GanttDate
    date: new XDate
  constructor: (options) ->
    options = {} unless options?
    @activities = options.activities if options.activities?
    @defaultWorkTimes = options.defaultWorkTimes if options.defaultWorkTimes?
  getCompiledActivities: ->
    activityList = []
    activityMap = {}
    # Initialise activities into the list and map
    dependantMap = @getDependantMap()
    for n, a of @activities
      a = _.clone a
      a.name = n
      a.dependants = dependantMap[n]
      activityMap[n] = activityList.length
      activityList.push a
    # Calculate starts and ends
    projectEnd = @startDate
    calculateStartAndEnd = (a) =>
      return a if a.startDate? and a.endDate?
      latestPreEnd = @startDate
      for pName in a.predecessors
        p = calculateStartAndEnd activityList[activityMap[pName]]
        latestPreEnd = p.endDate if p.endDate.comparable() > latestPreEnd.comparable()
      a.startDate = latestPreEnd
      a.endDate = @getActivitySchedule(a).getDateAfterDuration a.startDate, a.duration
      projectEnd = a.endDate if a.endDate.comparable() > projectEnd.comparable()
      a
    calculateStartAndEnd a for a in activityList
    # Calculate slack
    calculateLatestStartAndEnd = (a) =>
      return a if a.latestStartDate? and a.latestEndDate?
      earliestDepStart = projectEnd
      for dName in a.dependants
        d = calculateLatestStartAndEnd activityList[activityMap[dName]]
        earliestDepStart = d.latestStartDate if d.latestStartDate.comparable() < earliestDepStart.comparable()
      a.latestEndDate = earliestDepStart
      # Move to the end of the previous available day if currently at the start
      a.latestStartDate = @getActivitySchedule(a).getDateBeforeDuration earliestDepStart, a.duration
      a.critical = true if @getActivitySchedule(a).getHoursBetweenGanttDates(a.endDate, a.latestEndDate) <= 0
      a
    calculateLatestStartAndEnd a for a in activityList
    # Fix border start and latest end
    fixExtremeValues = (a) =>
      sched = @getActivitySchedule a
      # Move starts on the last hour of a day to the first hour of the next
      for offset in ['startDate', 'latestStartDate']
        ganttDate = a[offset]
        continue if ganttDate.hour < sched.getAvailableHoursForDate(ganttDate.date)
        d = GanttDate.isoToDate(ganttDate.date).addDays 1
        d = d.addDays(1) until sched.getAvailableHoursForDate d > 0
        a[offset] = new GanttDate
          date: d
          availableHours: sched.getAvailableHoursForDate(d)
      # Move ends on the first hour of a day to the last hour of the previous
      for offset in ['latestEndDate', 'latestEndDate']
        ganttDate = a[offset]
        continue if ganttDate.hour > 0
        d = GanttDate.isoToDate(ganttDate.date).addDays -1
        d = d.addDays(-1) until sched.getAvailableHoursForDate d > 0
        availHours = sched.getAvailableHoursForDate(d)
        a[offset] = new GanttDate
          date: d
          hour: availHours - 1
          availableHours: availHours
    fixExtremeValues a for a in activityList
    # Return the sorted list
    activityList.sort (a, b) ->
      return 1 if a.startDate.comparable() > b.startDate.comparable()
      return -1 if b.startDate.comparable() > a.startDate.comparable()
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
