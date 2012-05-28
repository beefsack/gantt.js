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
  nameWidth: 200
  activities: null
  context: null
  headerFont: 'bold 8pt sans-serif'
  activityFont: '10pt sans-serif'
  constructor: (options) ->
    @gantt = options.gantt if options.gantt?
    @reference = options.reference if options.reference?
  render: ->
    return unless @gantt? and @reference? and @reference.getContext?
    @context = @reference.getContext '2d'
    @activities = @gantt.getCompiledActivities()
    @context.canvas.width = @getWidth()
    @context.canvas.height = @getHeight()
    @drawGrid()
    @drawHeader()
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
      d = Gantt.dateToIso xd.addDays(1)
      console.log d
  renderActivity: (context) ->
  getHeaderHeight: ->
    @weekHeaderHeight + @dayHeaderHeight