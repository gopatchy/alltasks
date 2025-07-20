import Foundation
import SwiftData

class TaskSorter {
    static func sortTasks(_ tasks: [TaskItem], using comparisons: [Comparison]) -> [TaskItem] {
        // Start with the current order
        var sorted = Array(tasks)
        
        // Apply each comparison to enforce the ordering
        for comparison in comparisons.sorted(by: { $0.timestamp < $1.timestamp }) {
            // Find the indices of both tasks
            guard let winnerIndex = sorted.firstIndex(where: { $0.id == comparison.winner.id }),
                  let loserIndex = sorted.firstIndex(where: { $0.id == comparison.loser.id }) else {
                continue
            }
            
            // If winner comes after loser, move winner to just before loser
            if winnerIndex > loserIndex {
                let winner = sorted.remove(at: winnerIndex)
                sorted.insert(winner, at: loserIndex)
            }
        }
        
        return sorted
    }
}
