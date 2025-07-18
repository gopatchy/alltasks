import Foundation
import SwiftData

@Model
final class Comparison {
    var id = UUID()
    var sessionId: UUID
    var taskA: TaskItem
    var taskB: TaskItem
    var winner: TaskItem
    var timestamp: Date
    
    init(sessionId: UUID, taskA: TaskItem, taskB: TaskItem, winner: TaskItem) {
        self.sessionId = sessionId
        self.taskA = taskA
        self.taskB = taskB
        self.winner = winner
        self.timestamp = Date()
    }
    
    // Helper to check if this comparison involves these two tasks
    func involves(_ task1: TaskItem, _ task2: TaskItem) -> Bool {
        return (taskA.id == task1.id && taskB.id == task2.id) ||
               (taskA.id == task2.id && taskB.id == task1.id)
    }
}