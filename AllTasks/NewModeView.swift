import SwiftUI
import SwiftData

struct NewModeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var taskNew: TaskItem = TaskItem(title: "")
    @State private var taskInserted: Bool = false
    @State private var taskId: UUID = UUID()
    var tasks: Tasks
    @Binding var editing: Bool
    
    var body: some View {
        VStack {
            TaskDetailCard(
                task: taskNew,
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
        .onChange(of: taskNew.title) { oldValue, newValue in
            if !taskInserted && !newValue.isEmpty {
                tasks.insert(task: taskNew, modelContext: modelContext)
                taskInserted = true
            } else if taskInserted && !newValue.isEmpty {
                try? modelContext.save()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .modeSet)) { notification in
            guard notification.object as? ViewMode == .new else {
                return
            }
            
            if taskInserted {
                createNewTask()
            }
        }
    }
    
    private func createNewTask() {
        taskNew = TaskItem(title: "")
        taskInserted = false
        taskId = UUID()
    }
}
