import Foundation

typealias TasksFiltered = [TaskItem]

extension TasksFiltered {
    init(tasks: Tasks, taskFilter: TaskFilter, searchText: String) {
        self.init()
        
        for task in tasks {
            if task.matches(taskFilter: taskFilter, searchText: searchText) {
                self.append(task)
            }
        }
    }
}
