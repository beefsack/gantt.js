@ganttCanvas = new GanttCanvas
  reference: document.querySelector '#gantt-target'
  gantt: new Gantt 
    activities:
      'task 1':
        predecessors: []
        duration: 2
      'task 2':
        predecessors: []
        duration: 3
      'task 3':
        predecessors: [
          'task 1'
          'task 2'
        ]
        duration: 5
@ganttCanvas.render()
