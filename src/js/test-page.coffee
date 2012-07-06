@ganttFormSubmit = =>
  activityCount = Math.max(1, parseInt document.querySelector('#activityCount').value)
  activityLinkRate = Math.max(0, Math.min(1, parseFloat document.querySelector('#activityLinkRate').value))
  activities = {}
  for i in [1..activityCount]
    predecessors = []
    if i > 1
      predecessors.push("Task #{j}") for j in [1..(i - 1)] when Math.random() < activityLinkRate
    activities["Task #{i}"] = {
      predecessors: predecessors
      duration: (4 + Math.round(Math.random() * 100))
    }
  document.querySelector('#ganttData').value = JSON.stringify activities
  renderActivities activities
  false

@ganttLoadData = =>
  activities = JSON.parse document.querySelector('#ganttData').value
  renderActivities activities
  false

@renderActivities = (activities) ->
  @gantt = new Gantt
    activities: activities
  @ganttCanvas = new GanttCanvas
    reference: document.querySelector '#gantt-target'
    gantt: @gantt
  @ganttCanvas.gantt.schedules.default.overriddenWorkTimes['2012-07-05'] = 4
  @ganttCanvas.gantt.schedules.default.overriddenWorkTimes['2012-07-11'] = 4
  @ganttCanvas.draw()


@ganttFormSubmit()