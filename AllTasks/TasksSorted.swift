import Foundation

typealias TasksSorted = [TaskItem]

extension TasksSorted {
    init(tasks: [TaskItem]) {
        self.init()
        
        var taskByID: [UUID: TaskItem] = [:]
        var iter: TaskItem?

        for task in tasks {
            taskByID[task.id] = task

            if task.prevID == nil {
                iter = task
            }
        }
        
        self.reserveCapacity(taskByID.count)
        
        while let task = iter {
            if let prevID = task.prevID {
                task.prevTask = taskByID[prevID]
            }
            
            if let nextID = task.nextID {
                task.nextTask = taskByID[nextID]
            }
            
            self.append(task)
            
            iter = task.nextTask
        }
    }
}
