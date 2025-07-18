import SwiftUI
import SwiftData

struct ListModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @Binding var selectedTask: TaskItem?
    @FocusState var isFocused: Bool
    
    var sortedTasks: [TaskItem] {
        TaskSorter.sortTasks(tasks, using: comparisons)
    }
    
    var body: some View {
        HSplitView {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(sortedTasks) { task in
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
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTask?.id == task.id ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTask?.id == task.id ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                            .onTapGesture {
                                selectedTask = task
                            }
                            .id(task.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .onChange(of: selectedTask) { _, newTask in
                    if let task = newTask {
                        Task { @MainActor in
                            proxy.scrollTo(task.id, anchor: .center)
                        }
                    }
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
                .onAppear {
                    isFocused = true
                    // Select first task if none selected
                    if selectedTask == nil && !sortedTasks.isEmpty {
                        selectedTask = sortedTasks.first
                    }
                    // Scroll to selected task when view appears
                    if let task = selectedTask {
                        Task { @MainActor in
                            proxy.scrollTo(task.id, anchor: .center)
                        }
                    }
                }
            }
            
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
        .onDisappear {
            // Clear focus when leaving the view
            isFocused = false
        }
    }
    
    private func selectNextTask() {
        guard let currentTask = selectedTask,
              let currentIndex = sortedTasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex < sortedTasks.count - 1 else { return }
        
        selectedTask = sortedTasks[currentIndex + 1]
    }
    
    private func selectPreviousTask() {
        guard let currentTask = selectedTask,
              let currentIndex = sortedTasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex > 0 else { return }
        
        selectedTask = sortedTasks[currentIndex - 1]
    }
}
