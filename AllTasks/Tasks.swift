import Foundation
import SwiftData

@Observable
class Tasks {
    private(set) var tasks: [TaskItem] = []
    
    func update(from taskItems: [TaskItem]) {
        var taskMap: [UUID : TaskItem] = [:]
        var iter: TaskItem?
        
        for task in taskItems {
            taskMap[task.id] = task
            
            if task.previousID == nil {
                if let iter2 = iter {
                    print("multiple first tasks: \(iter2) vs \(task)")
                }
                
                iter = task
            }
        }
        
        tasks.removeAll()
        
        while let iter2 = iter {
            tasks.append(iter2)
            
            if let nextID = iter2.nextID {
                iter = taskMap[nextID]
            } else {
                iter = nil
            }
        }
    }
    
    func selectPrevious(from currentTask: TaskItem?) -> TaskItem? {
        guard !tasks.isEmpty else { return nil }
        
        if let currentTask = currentTask,
           let currentIndex = tasks.firstIndex(where: { $0.id == currentTask.id }) {
            let newIndex = (currentIndex - 1) % tasks.count
            let wrappedIndex = newIndex < 0 ? newIndex + tasks.count : newIndex
            return tasks[wrappedIndex]
        } else {
            return tasks.first
        }
    }
    
    func selectNext(from currentTask: TaskItem?) -> TaskItem? {
        guard !tasks.isEmpty else { return nil }
        
        if let currentTask = currentTask,
           let currentIndex = tasks.firstIndex(where: { $0.id == currentTask.id }) {
            let newIndex = (currentIndex + 1) % tasks.count
            let wrappedIndex = newIndex < 0 ? newIndex + tasks.count : newIndex
            return tasks[wrappedIndex]
        } else {
            return tasks.first
        }
    }
    
    func filter(by filter: TaskFilter, searchText: String) -> [TaskItem] {
        // Apply task filter
        let filtered = switch filter {
        case .incomplete:
            tasks.filter { !$0.complete }
        case .all:
            tasks
        case .complete:
            tasks.filter { $0.complete }
        }
        
        // Apply search filter
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.details.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
