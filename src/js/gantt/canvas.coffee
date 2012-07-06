class @GanttCanvas
  gantt: null
  reference: null
  dayWidth: 20
  rowHeight: 30
  weekHeaderHeight: 25
  dayHeaderHeight: 25
  majorGridWidth: 1
  minorGridWidth: 1
  minorGridColour: '#CCCCCC'
  majorGridColour: '#000000'
  availShade: 255
  unavailShade: 150
  nameWidth: 200
  activities: null
  activityIndex: {}
  context: null
  headerFont: 'bold 8pt sans-serif'
  headerFontColour: '#000000'
  activityNamePadding: 5
  activityFont: '8pt sans-serif'
  activityFontColour: '#000000'
  activityPadding: 5
  activityCompleteColour: '#00FF00'
  activityIncompleteColour: '#EEEEEE'
  activityCritical: '#FF6666'
  activitySlack: '#3399FF'
  activitySlackLine: '#333333'
  activitySlackBar: 'rgba(51,153,255,0.4)'
  activitySlackBarHeight: 6
  activityLineWidth: 2
  arrowBuffer: 8
  arrowRegister: {}
  arrowHeadSize: 3
  shadowOffsetX: 3
  shadowOffsetY: 3
  shadowColor: 'rgba(100,100,100,100)'
  shadowBlur: 5
  constructor: (options) ->
    @gantt = options.gantt if options.gantt?
    @reference = options.reference if options.reference?
  draw: ->
    return unless @gantt? and @reference? and @reference.getContext?
    @arrowRegister = {}
    @context = @reference.getContext '2d'
    @activities = @gantt.getCompiledActivities()
    # Build index for quick referencing
    @activityIndex[a.name] = a for a in @activities
    @context.canvas.width = @getWidth()
    @context.canvas.height = @getHeight()
    @drawGrid()
    @drawHeader()
    @drawActivities()
  getHeight: ->
    return 0 if @activities.length is 0
    @activities.length * @rowHeight + @getHeaderHeight()
  getWidth: ->
    return 0 if @activities.length is 0
    @nameWidth + @dayWidth * @getDays()
  getStartDate: ->
    return null if @activities.length is 0
    _.first(@activities).startDate.date
  getEndDate: ->
    return null if @activities.length is 0
    _.last(@activities).endDate.date
  getDays: ->
    return 0 if @activities.length is 0
    (new XDate(@getStartDate())).diffDays(new XDate(@getEndDate())) + 1    
  getStartDate: ->
    return null if @activities.length is 0
    _.first(@activities).startDate.date
  drawGrid: ->
    # Minor grid
    @context.strokeStyle = @minorGridColour
    @context.lineWidth = @minorGridWidth
    @context.beginPath()
    # Minor grid - horizontals
    y = @getHeaderHeight() + @rowHeight
    for i in [1..@activities.length]
      @context.moveTo 0, y + 0.5
      @context.lineTo @getWidth(), y + 0.5
      y += @rowHeight
    # Minor grid - above vertical major
    @context.moveTo @nameWidth + 0.5, 0
    @context.lineTo @nameWidth + 0.5, @getHeaderHeight()
    # Minor grid - horizontal separator in week
    @context.moveTo @nameWidth, @weekHeaderHeight + 0.5
    @context.lineTo @getWidth(), @weekHeaderHeight + 0.5
    # Minor grid - Week horizontals
    x = @nameWidth + @dayWidth
    for i in [1..@getDays()]
      @context.moveTo x + 0.5, @weekHeaderHeight
      @context.lineTo x + 0.5, @getHeight()
      x += @dayWidth
    @context.stroke()
    # Major horizontal and vertical
    @context.strokeStyle = @majorGridColour
    @context.lineWidth = @majorGridWidth
    @context.beginPath()
    @context.moveTo 0, @getHeaderHeight() + 0.5
    @context.lineTo @getWidth(), @getHeaderHeight() + 0.5
    @context.moveTo @nameWidth + 0.5, @getHeaderHeight()
    @context.lineTo @nameWidth + 0.5, @getHeight()
    @context.stroke()
  drawHeader: ->
    x = @nameWidth
    d = @getStartDate()
    e = @getEndDate()
    @context.font = @headerFont
    @context.fillStyle = @headerFontColour
    while d <= e
      xd = new XDate d
      # Write the day
      @context.textAlign = 'center'
      @context.textBaseline = 'middle'
      wd = xd.toString('ddd')
      @context.fillText wd.substring(0, 1), x + @dayWidth / 2, @weekHeaderHeight + @dayHeaderHeight / 2
      # Write the date text if required
      if wd is 'Mon'
        # Write date
        @context.textAlign = 'left'
        @context.textBaseline = 'middle'
        @context.fillText d, x + @dayWidth / 2 - 4, @weekHeaderHeight / 2
        # Draw extra minor line at x
        @context.strokeStyle = @minorGridColour
        @context.lineWidth = @minorGridWidth
        @context.beginPath()
        @context.moveTo x + 0.5, 0
        @context.lineTo x + 0.5, @weekHeaderHeight
        @context.stroke()
      x += @dayWidth
      d = GanttDate.dateToIso xd.addDays(1)
  drawActivities: ->
    y = @getHeaderHeight()
    activityLinePositions = {}
    for a in @activities
      # Write the name
      @context.font = @activityFont
      @context.fillStyle = @activityFontColour
      @context.textAlign = 'left'
      @context.textBaseline = 'middle'
      @context.fillText a.name, @activityNamePadding, y + @rowHeight / 2, @nameWidth - @activityNamePadding * 2
      # Fill in the cell availabilities
      x = @nameWidth
      d = @getStartDate()
      e = @getEndDate()
      # Go through the days until we find the final day
      while d <= e
        s = @gantt.getActivitySchedule a
        hours = s.getAvailableHoursForDate d
        # Find out the percentage of 8 and make it white to grey based on ratio
        @context.fillStyle = @getAvailColour hours / 8
        @context.fillRect x + 1, y + 1, @dayWidth - 1, @rowHeight - 1
        xd = new XDate d
        startDayX = x if a.startDate.date is d
        endDayX = x if a.endDate.date is d
        slackEndDayX = x if a.latestEndDate.date is d
        x += @dayWidth
        d = GanttDate.dateToIso xd.addDays(1)
      # Calculate the positioning for the activity rectangle
      startDayAvailHours = @gantt.getActivitySchedule(a).getAvailableHoursForDate a.startDate.date
      startDayRatio = a.startDate.hour / startDayAvailHours
      startDayOffset = @getDayInnerWidth() * startDayRatio
      endDayAvailHours = @gantt.getActivitySchedule(a).getAvailableHoursForDate a.endDate.date
      endDayRatio = a.endDate.hour / endDayAvailHours
      endDayOffset = @getDayInnerWidth() * endDayRatio
      # Draw slack if required
      slackEndDayAvailHours = @gantt.getActivitySchedule(a).getAvailableHoursForDate a.latestEndDate.date
      slackEndDayRatio = a.latestEndDate.hour / slackEndDayAvailHours
      slackEndDayOffset = @getDayInnerWidth() * slackEndDayRatio
      @context.fillStyle = @activityIncompleteColour
      a.x = Math.round(startDayX + @activityPadding + startDayOffset)
      a.y = y + @activityPadding
      a.width = Math.round(endDayX - startDayX - startDayOffset + endDayOffset)
      a.height = @rowHeight - @activityPadding * 2
      a.slack =
        x: a.x + a.width
        y: a.y + Math.round(a.height / 3 - @activitySlackBarHeight / 2)
        width: slackEndDayX - endDayX - endDayOffset + slackEndDayOffset
        height: @activitySlackBarHeight
      @drawActivity a
      # Draw border
      y += @rowHeight
      if a.predecessors.length > 0
        # Reserve a line position
        linePos = Math.round((a.x + @arrowBuffer) / @arrowBuffer) * @arrowBuffer
        while @arrowExists linePos
          linePos += @arrowBuffer
        @registerArrow linePos
        activityLinePositions[a.name] = linePos
    # Draw arrows
    for a in @activities
      arrowStartX = a.x + a.width + Math.floor(@activityLineWidth / 2)
      arrowStartY = Math.round(a.y + a.height / 3 * 2)
      for dName in a.dependants
        d = @activityIndex[dName]
        arrowEndY = d.y - @activityLineWidth
        # Calculate curve positions
        curveStart = Math.max(arrowStartX, activityLinePositions[dName] - @arrowBuffer)
        # Draw horizontal
        @context.strokeStyle = @activitySlackLine
        @context.lineWidth = @activityLineWidth
        @context.beginPath()
        @context.moveTo arrowStartX, arrowStartY
        @context.lineTo curveStart, arrowStartY
        # Draw curve
        @context.bezierCurveTo curveStart + @arrowBuffer / 3, arrowStartY, activityLinePositions[dName], arrowStartY + @arrowBuffer / 3 * 2, activityLinePositions[dName], arrowStartY + @arrowBuffer
        # Draw vertical
        @context.lineTo activityLinePositions[dName], arrowEndY
        @context.lineTo activityLinePositions[dName] - @arrowHeadSize, arrowEndY - @arrowHeadSize
        @context.moveTo activityLinePositions[dName], arrowEndY
        @context.lineTo activityLinePositions[dName] + @arrowHeadSize, arrowEndY - @arrowHeadSize
        @context.stroke()
  drawActivity: (a) ->
    # Do the fill
    @enableShadow()
    @context.fillRect a.x, a.y, a.width, a.height
    @disableShadow()
    # Do the border
    @context.strokeStyle = if a.critical then @activityCritical else @activitySlack
    @context.lineWidth = @activityLineWidth
    @context.strokeRect a.x, a.y, a.width, a.height
    # Draw the slack, if any
    unless a.critical
      @context.fillStyle = @activitySlackBar
      @context.fillRect a.slack.x, a.slack.y, a.slack.width, a.slack.height
  getHeaderHeight: ->
    @weekHeaderHeight + @dayHeaderHeight
  getAvailColour: (ratio) ->
    ratio = Math.max 0, Math.min(ratio, 1)
    diff = Math.abs @availShade - @unavailShade
    diffRatio = diff * ratio
    shade = Math.round Math.min(@unavailShade, @availShade) + diffRatio
    "rgb(#{shade},#{shade},#{shade})"
  getDayInnerWidth: ->
    @dayWidth - @activityPadding * 2
  enableShadow: ->
    @context.shadowOffsetX = @shadowOffsetX
    @context.shadowOffsetY = @shadowOffsetY
    @context.shadowColor = @shadowColor
    @context.shadowBlur = @shadowBlur
  disableShadow: ->
    @context.shadowColor = 'rgba(0,0,0,0)'
  registerArrow: (x) -> @arrowRegister[Math.round(x / @arrowBuffer)] = true
  arrowExists: (x) -> @arrowRegister[Math.round(x / @arrowBuffer)]?