import Foundation
import SwiftData

class TaskSorter {
    static func sortTasks(_ tasks: [TaskItem], using comparisons: [Comparison]) -> [TaskItem] {
        // Separate completed and incomplete tasks
        var incompleteTasks = tasks.filter { !$0.isCompleted }
        let completedTasks = tasks.filter { $0.isCompleted }
        
        // Start with the current order
        var sorted = incompleteTasks
        
        // Apply each comparison to enforce the ordering
        for comparison in comparisons.sorted(by: { $0.timestamp < $1.timestamp }) {
            // Find the indices of both tasks
            guard let winnerIndex = sorted.firstIndex(where: { $0.id == comparison.winner.id }),
                  let loserIndex = sorted.firstIndex(where: { 
                      $0.id == (comparison.winner.id == comparison.taskA.id ? comparison.taskB.id : comparison.taskA.id) 
                  }) else {
                continue
            }
            
            // If winner comes after loser, move winner to just before loser
            if winnerIndex > loserIndex {
                let winner = sorted.remove(at: winnerIndex)
                sorted.insert(winner, at: loserIndex)
            }
        }
        
        // Return incomplete tasks first, then completed tasks
        return sorted + completedTasks
    }
}