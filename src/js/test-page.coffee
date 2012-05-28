@ganttCanvas = new GanttCanvas
  reference: document.querySelector '#gantt-target'
  gantt: new Gantt 
    activities:
      'task 1':
        predecessors: []
        duration: 50
      'task 2':
        predecessors: []
        duration: 60
      'task 3':
        predecessors: [
          'task 1'
          'task 2'
        ]
        duration: 30
@ganttCanvas.draw()
