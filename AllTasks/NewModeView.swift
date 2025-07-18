import SwiftUI
import SwiftData

struct NewModeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentTask: TaskItem = TaskItem(title: "")
    @State private var isTaskInserted: Bool = false
    @State private var taskId: UUID = UUID()
    
    var body: some View {
        VStack {
            TaskDetailCard(task: currentTask, isEditable: true, focusTitleOnAppear: true)
                .frame(maxWidth: 600)
                .padding()
                .id(taskId)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Force recreation of TaskDetailCard to trigger focus
            taskId = UUID()
        }
        .onChange(of: currentTask.title) { oldValue, newValue in
            // Insert task into database when user starts typing
            if !isTaskInserted && !newValue.isEmpty {
                modelContext.insert(currentTask)
                isTaskInserted = true
                try? modelContext.save()
            } else if isTaskInserted && !newValue.isEmpty {
                // Auto-save changes
                try? modelContext.save()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .createNewTask)) { _ in
            if isTaskInserted {
                createNewTask()
            }
        }
    }
    
    private func createNewTask() {
        // Create a new task and reset state
        currentTask = TaskItem(title: "")
        isTaskInserted = false
        taskId = UUID() // Force TaskDetailCard to recreate and focus
    }
}