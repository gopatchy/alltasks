import SwiftUI
import SwiftData

struct ListModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTask: TaskItem?
    let sortedTasks: [TaskItem]
    @Binding var editing: Bool
    
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
                        proxy.scrollTo(task.id, anchor: .center)
                    }
                }
                .focusable()
                .focusEffectDisabled()
                }
                .frame(minWidth: 250)
                .onAppear {
                    // Select first task if none selected
                    if selectedTask == nil && !sortedTasks.isEmpty {
                        selectedTask = sortedTasks.first
                    }
                    // Scroll to selected task when view appears
                    if let task = selectedTask {
                        proxy.scrollTo(task.id, anchor: .center)
                    }
                }
            }
            
            VStack {
                if let task = selectedTask {
                    TaskDetailCard(
                        task: task,
                        editing: $editing
                    )
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
    }
}
