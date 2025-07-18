import SwiftUI
import SwiftData

struct PrioritizeModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @State private var currentPairIndex = 0
    @State private var comparisons: [(TaskItem, TaskItem)] = []
    @FocusState private var isFocused: Bool
    
    var incompleteTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }
    
    var currentPair: (TaskItem, TaskItem)? {
        guard currentPairIndex < comparisons.count else { return nil }
        return comparisons[currentPairIndex]
    }
    
    var body: some View {
        VStack {
            if incompleteTasks.count < 2 {
                Text("Add at least 2 tasks to use prioritize mode")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let pair = currentPair {
                VStack {
                    HStack(spacing: 0) {
                        TaskComparisonView(
                            task: pair.0,
                            action: { selectTask(pair.0, over: pair.1) },
                            color: .purple,
                            alignment: .leading
                        )
                        
                        TaskComparisonView(
                            task: pair.1,
                            action: { selectTask(pair.1, over: pair.0) },
                            color: .purple,
                            alignment: .trailing
                        )
                    }
                    
                    ProgressView(value: Double(currentPairIndex), total: Double(comparisons.count))
                        .progressViewStyle(.linear)
                        .tint(.purple)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Prioritization Complete!")
                        .font(.title)
                    
                    Button("Start Over") {
                        setupComparisons()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .focusable()
        .focused($isFocused)
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) {
            if let pair = currentPair {
                selectTask(pair.0, over: pair.1)
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.rightArrow) {
            if let pair = currentPair {
                selectTask(pair.1, over: pair.0)
                return .handled
            }
            return .ignored
        }
        .onAppear {
            setupComparisons()
            isFocused = true
        }
    }
    
    private func setupComparisons() {
        comparisons = []
        let tasks = incompleteTasks
        
        for i in 0..<tasks.count {
            for j in (i+1)..<tasks.count {
                comparisons.append((tasks[i], tasks[j]))
            }
        }
        
        comparisons.shuffle()
        currentPairIndex = 0
    }
    
    private func selectTask(_ winner: TaskItem, over loser: TaskItem) {
        // In a real app, you might want to track priority scores
        nextComparison()
    }
    
    private func nextComparison() {
        currentPairIndex += 1
    }
}

struct TaskComparisonView: View {
    let task: TaskItem
    let action: () -> Void
    let color: Color
    let alignment: Alignment
    
    var body: some View {
        VStack(spacing: 16) {
            TaskDetailCard(task: task, isEditable: false)
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
                        .background(color.opacity(0.8))
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
