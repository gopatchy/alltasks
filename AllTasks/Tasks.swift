import SwiftData

typealias Tasks = [TaskItem]

private let priorityDefault: Int64 = 0
private let priorityOffset: Int64 = 1 << 32

extension Tasks {
    func insert(task: TaskItem, modelContext: ModelContext) {
        if let insertBefore = self.first {
            task.priority = insertBefore.priority + priorityOffset
        } else {
            task.priority = priorityDefault
        }
        
        try! modelContext.transaction {
            modelContext.insert(task)
        }
    }
}
