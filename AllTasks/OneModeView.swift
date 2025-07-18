import SwiftUI
import SwiftData

struct OneModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @State private var currentTaskIndex = 0
    @FocusState private var isOneModeViewFocused: Bool
    @Binding var selectedTask: TaskItem?
    
    var incompleteTasks: [TaskItem] {
        let incomplete = tasks.filter { !$0.isCompleted }
        return TaskSorter.sortTasks(incomplete, using: comparisons)
    }
    
    var body: some View {
        VStack {
            if let task = selectedTask {
                VStack(spacing: 30) {
                    HStack(alignment: .center, spacing: 20) {
                        VStack {
                            Button(action: previousTask) {
                                Image(systemName: "chevron.left")
                                    .font(.title)
                            }
                            .keyboardShortcut(.leftArrow, modifiers: [])
                            
                            Button(action: {
                                currentTaskIndex = 0
                            }) {
                                Image(systemName: "chevron.left.2")
                                    .font(.title2)
                            }
                            .disabled(currentTaskIndex == 0)
                            .keyboardShortcut("1", modifiers: [])
                        }
                        
                        TaskDetailCard(task: task, isEditable: false)
                        .frame(maxWidth: 600)
                        .padding()
                        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                        
                        VStack {
                            Button(action: nextTask) {
                                Image(systemName: "chevron.right")
                                    .font(.title)
                            }
                            .keyboardShortcut(.rightArrow, modifiers: [])
                            
                            Button(action: {
                                currentTaskIndex = incompleteTasks.count - 1
                            }) {
                                Image(systemName: "chevron.right.2")
                                    .font(.title2)
                            }
                            .disabled(currentTaskIndex == incompleteTasks.count - 1)
                            .keyboardShortcut("2", modifiers: [])
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No active tasks")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Text("Add some tasks to get started")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onKeyPress(.leftArrow) {
            previousTask()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            nextTask()
            return .handled
        }
        .onAppear {
            // If we have a selected task, find its index
            if let task = selectedTask,
               let index = incompleteTasks.firstIndex(where: { $0.id == task.id }) {
                currentTaskIndex = index
            }
            updateCurrentTask()
        }
        .onChange(of: incompleteTasks) { _, _ in
            updateCurrentTask()
        }
        .focused($isOneModeViewFocused)
    }
    
    private func nextTask() {
        if currentTaskIndex < incompleteTasks.count - 1 {
            currentTaskIndex += 1
        } else {
            currentTaskIndex = 0
        }
        updateCurrentTask()
    }
    
    private func previousTask() {
        if currentTaskIndex > 0 {
            currentTaskIndex -= 1
        } else {
            currentTaskIndex = incompleteTasks.count - 1
        }
        updateCurrentTask()
    }
    
    private func updateCurrentTask() {
        guard !incompleteTasks.isEmpty else {
            selectedTask = nil
            return
        }
        
        // Ensure index is valid
        currentTaskIndex = currentTaskIndex % incompleteTasks.count
        selectedTask = incompleteTasks[currentTaskIndex]
    }
}