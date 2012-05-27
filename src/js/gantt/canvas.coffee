class @GanttCanvas
  gantt: null
  reference: null
  dayWidth: 20
  constructor: (options) ->
    @gantt = options.gantt if options.gantt?
    @reference = options.reference if options.reference?
  render: ->
    return unless @gantt? and @reference? and @reference.getContext?
    context = @reference.getContext '2d'
    starts = @gantt.calculateStarts()
    console.log @gantt.activities
  renderActivity: (context) ->
