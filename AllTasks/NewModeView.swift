import SwiftUI
import SwiftData

struct NewModeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentTask: TaskItem = TaskItem(title: "")
    @State private var isTaskInserted: Bool = false
    @State private var taskId: UUID = UUID()
    @Binding var tasksSorted: TasksSorted
    @Binding var editing: Bool
    
    var body: some View {
        VStack {
            TaskDetailCard(
                task: currentTask,
                editing: $editing,
                focusTitleOnAppear: true
            )
                .frame(maxWidth: 600)
                .padding()
                .id(taskId)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            taskId = UUID()
        }
        .onChange(of: currentTask.title) { oldValue, newValue in
            if !isTaskInserted && !newValue.isEmpty {
                try! modelContext.transaction {
                    if let firstTask = tasksSorted.first {
                        currentTask.nextID = firstTask.id
                        firstTask.prevID = currentTask.id
                    }
                    modelContext.insert(currentTask)
                    isTaskInserted = true
                }
            } else if isTaskInserted && !newValue.isEmpty {
                try? modelContext.save()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newTask)) { _ in
            if isTaskInserted {
                createNewTask()
            }
        }
    }
    
    private func createNewTask() {
        currentTask = TaskItem(title: "")
        isTaskInserted = false
        taskId = UUID()
    }
}
