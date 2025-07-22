import SwiftUI
import SwiftData

struct PrioritizeModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @State private var sortingState: SortingState = SortingState()
    @State private var currentComparison: (TaskItem, TaskItem)?
    @State private var sortedTasks: [TaskItem] = []
    @State private var currentSessionId = UUID()
    @Binding var editing: Bool
    
    var incompleteTasks: [TaskItem] {
        tasks.filter { !$0.complete }
    }
    
    struct SortingState {
        var mergeStack: [(start: Int, mid: Int, end: Int)] = []
        var currentMerge: (left: [TaskItem], right: [TaskItem], result: [TaskItem])?
        var comparisonsCount = 0
    }
    
    var body: some View {
        VStack {
            if incompleteTasks.count < 2 {
                Text("Add at least 2 tasks to use prioritize mode")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let comparison = currentComparison {
                VStack {
                    HStack(spacing: 0) {
                        TaskComparisonView(
                            task: comparison.0,
                            action: { selectTask(comparison.0) },
                            alignment: .leading,
                            editing: $editing,
                        )
                        
                        TaskComparisonView(
                            task: comparison.1,
                            action: { selectTask(comparison.1) },
                            alignment: .trailing,
                            editing: $editing,
                        )
                    }
                    
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Prioritization Complete")
                        .font(.title)
                    
                    Text("Your tasks have been prioritized")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onKeyPress(.leftArrow) {
            if let comparison = currentComparison {
                selectTask(comparison.0)
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.rightArrow) {
            if let comparison = currentComparison {
                selectTask(comparison.1)
                return .handled
            }
            return .ignored
        }
        .onAppear {
            startSorting()
        }
    }
    
    private func startSorting() {
        sortedTasks = incompleteTasks
        sortingState = SortingState()
        currentComparison = nil
        currentSessionId = UUID() // New session for each sort
        
        if sortedTasks.count > 1 {
            // Initialize merge sort
            initializeMergeSort(0, sortedTasks.count - 1)
            processNextComparison()
        }
        // If <= 1 task, currentComparison stays nil, showing completion
    }
    
    private func initializeMergeSort(_ start: Int, _ end: Int) {
        if start < end {
            let mid = (start + end) / 2
            initializeMergeSort(start, mid)
            initializeMergeSort(mid + 1, end)
            sortingState.mergeStack.append((start, mid, end))
        }
    }
    
    private func processNextComparison() {
        // Continue current merge if in progress
        if var merge = sortingState.currentMerge {
            if !merge.left.isEmpty && !merge.right.isEmpty {
                let left = merge.left[0]
                let right = merge.right[0]
                
                // Check if we have a recent comparison for this pair
                if let existingWinner = checkExistingComparison(left, right) {
                    // Use existing comparison result
                    if existingWinner.id == left.id {
                        merge.result.append(merge.left.removeFirst())
                    } else {
                        merge.result.append(merge.right.removeFirst())
                    }
                    sortingState.currentMerge = merge
                    processNextComparison()
                } else {
                    // Need user input
                    currentComparison = (left, right)
                }
                return
            }
            
            // Finish current merge
            while !merge.left.isEmpty {
                merge.result.append(merge.left.removeFirst())
            }
            while !merge.right.isEmpty {
                merge.result.append(merge.right.removeFirst())
            }
            
            // Apply merge result
            if let mergeInfo = sortingState.mergeStack.first {
                for (i, task) in merge.result.enumerated() {
                    sortedTasks[mergeInfo.start + i] = task
                }
                sortingState.mergeStack.removeFirst()
            }
            sortingState.currentMerge = nil
        }
        
        // Start next merge
        if let mergeInfo = sortingState.mergeStack.first {
            let leftArray = Array(sortedTasks[mergeInfo.start...mergeInfo.mid])
            let rightArray = Array(sortedTasks[(mergeInfo.mid + 1)...mergeInfo.end])
            
            sortingState.currentMerge = (left: leftArray, right: rightArray, result: [])
            processNextComparison()
        } else {
            // Sorting complete
            currentComparison = nil
        }
    }
    
    private func selectTask(_ selected: TaskItem) {
        guard var merge = sortingState.currentMerge,
              let comparison = currentComparison else { return }
        
        sortingState.comparisonsCount += 1
        
        // Determine winner and loser
        let loser = selected.id == comparison.0.id ? comparison.1 : comparison.0
        
        // Save the comparison for this session
        let newComparison = Comparison(sessionId: currentSessionId, winner: selected, loser: loser)
        modelContext.insert(newComparison)
        
        // Remove old comparisons for this pair (from any session)
        let oldComparisons = comparisons.filter { comp in
            comp.involves(comparison.0, comparison.1) && comp.id != newComparison.id
        }
        for old in oldComparisons {
            modelContext.delete(old)
        }
        
        if selected.id == comparison.0.id {
            merge.result.append(merge.left.removeFirst())
        } else {
            merge.result.append(merge.right.removeFirst())
        }
        
        sortingState.currentMerge = merge
        processNextComparison()
    }
    
    private func checkExistingComparison(_ taskA: TaskItem, _ taskB: TaskItem) -> TaskItem? {
        // Find comparisons from the current session only
        let relevantComparison = comparisons
            .filter { $0.sessionId == currentSessionId && $0.involves(taskA, taskB) }
            .sorted { $0.timestamp > $1.timestamp }
            .first
        
        return relevantComparison?.winner
    }
}

struct TaskComparisonView: View {
    let task: TaskItem
    let action: () -> Void
    let alignment: Alignment
    @Binding var editing: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            TaskDetailCard(
                task: task,
                editing: $editing,
                releaseFocus: false
            )
                .glassEffect(in: RoundedRectangle(cornerRadius: 8))
            
            HStack {
                if alignment == .leading {
                    Spacer()
                }
                
                Button(action: action) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 100)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.8))
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(alignment == .leading ? "1" : "2", modifiers: [])
                
                if alignment == .trailing {
                    Spacer()
                }
            }
        }
        .padding()
    }
}
