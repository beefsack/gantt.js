@activities = {}
@activityCount = 30 + Math.round(Math.random() * 20)
for i in [1..@activityCount - 1]
  predecessors = []
  predecessors.push("Task #{j}") for j in [1..(i - 1)] when Math.random() > 0.90
  @activities["Task #{i}"] = {
    predecessors: predecessors
    duration: (4 + Math.round(Math.random() * 100))
  }
@ganttCanvas = new GanttCanvas
  reference: document.querySelector '#gantt-target'
  gantt: new Gantt 
    activities: @activities
      # 'task 1':
      #   predecessors: []
      #   duration: 50
      # 'task 2':
      #   predecessors: []
      #   duration: 60
      # 'task 3':
      #   predecessors: [
      #     'task 1'
      #     'task 2'
      #   ]
      #   duration: 30
@ganttCanvas.gantt.schedules.default.overriddenWorkTimes['2012-07-05'] = 4
@ganttCanvas.gantt.schedules.default.overriddenWorkTimes['2012-07-11'] = 4
@ganttCanvas.draw()
