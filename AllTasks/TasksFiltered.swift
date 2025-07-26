import Foundation

typealias TasksFiltered = [TaskItem]

extension TasksFiltered {
    init(tasksSorted: TasksSorted, taskFilter: TaskFilter, searchText: String) {
        self.init()
        
        for task in tasksSorted {
            if task.matches(taskFilter: taskFilter, searchText: searchText) {
                self.append(task)
            }
        }
    }
}
