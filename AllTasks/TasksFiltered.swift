import Foundation

typealias TasksFiltered = [TaskItem]

extension TasksFiltered {
    init(tasksSorted: TasksSorted, taskFilter: TaskFilter, searchText: String) {
        self.init()
        
        for task in tasksSorted {
            guard task.matches(taskFilter: taskFilter, searchText: searchText) else {
                continue
            }
            
            task.nextTask = nil
        
            if self.last == nil {
                task.prevTask = nil
            } else {
                task.prevTask = self.last
                self.last!.nextTask = task
            }
            
            self.append(task)
        }
    }
}
