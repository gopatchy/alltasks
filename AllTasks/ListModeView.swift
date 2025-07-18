import SwiftUI
import SwiftData

struct ListModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Binding var selectedTask: TaskItem?
    @FocusState var isFocused: Bool
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(tasks) { task in
                            HStack {
                                Button(action: {
                                    task.isCompleted.toggle()
                                }) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .purple : .gray)
                                        .font(.title3)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                    .foregroundColor(task.isCompleted ? .gray : .primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTask?.id == task.id ? Color.accentColor.opacity(0.1) : Color.clear)
                            )
                            .onTapGesture {
                                selectedTask = task
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .focusable()
                .focused($isFocused)
                .focusEffectDisabled()
                .onKeyPress(.downArrow) {
                    selectNextTask()
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    selectPreviousTask()
                    return .handled
                }
            }
            .frame(minWidth: 250)
            
            VStack {
                if let task = selectedTask {
                    TaskDetailCard(task: task, isEditable: false)
                        .padding()
                        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                        .padding()
                } else {
                    Text("Select a task to view details")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth: 300)
        }
        .onAppear {
            isFocused = true
            // Select first task if none selected
            if selectedTask == nil && !tasks.isEmpty {
                selectedTask = tasks.first
            }
        }
    }
    
    private func selectNextTask() {
        guard let currentTask = selectedTask,
              let currentIndex = tasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex < tasks.count - 1 else { return }
        
        selectedTask = tasks[currentIndex + 1]
    }
    
    private func selectPreviousTask() {
        guard let currentTask = selectedTask,
              let currentIndex = tasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex > 0 else { return }
        
        selectedTask = tasks[currentIndex - 1]
    }
}
