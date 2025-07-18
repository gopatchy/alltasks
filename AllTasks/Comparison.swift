import Foundation
import SwiftData

@Model
final class Comparison {
    var id = UUID()
    var sessionId: UUID
    var winner: TaskItem
    var loser: TaskItem
    var timestamp: Date
    
    init(sessionId: UUID, winner: TaskItem, loser: TaskItem) {
        self.sessionId = sessionId
        self.winner = winner
        self.loser = loser
        self.timestamp = Date()
    }
    
    // Helper to check if this comparison involves these two tasks
    func involves(_ task1: TaskItem, _ task2: TaskItem) -> Bool {
        return (winner.id == task1.id && loser.id == task2.id) ||
               (winner.id == task2.id && loser.id == task1.id)
    }
}