@activities = {}
@activityCount = 30
@gantt = new Gantt
  activities: @activities
for i in [1..@activityCount - 1]
  predecessors = []
  if i > 1
    predecessors.push("Task #{j}") for j in [1..(i - 1)] when Math.random() > 0.90
  @activities["Task #{i}"] = {
    predecessors: predecessors
    duration: (4 + Math.round(Math.random() * 100))
  }
@ganttCanvas = new GanttCanvas
  reference: document.querySelector '#gantt-target'
  gantt: @gantt
@ganttCanvas.gantt.schedules.default.overriddenWorkTimes['2012-07-05'] = 4
@ganttCanvas.gantt.schedules.default.overriddenWorkTimes['2012-07-11'] = 4
@ganttCanvas.draw()
