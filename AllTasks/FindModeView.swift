import SwiftUI
import SwiftData

struct FindModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTask: TaskItem?
    @Binding var searchText: String
    let filteredTasks: [TaskItem]
    @FocusState private var isSearchFieldFocused: Bool
    @Binding var editing: Bool
    
    var body: some View {
        HSplitView {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                    
                        TextField("Search tasks...", text: $searchText)
                            .textFieldStyle(.plain)
                            .focused($isSearchFieldFocused)
                            .onSubmit {
                                if !filteredTasks.isEmpty {
                                    selectedTask = filteredTasks.first
                                }
                            }
                    
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                isSearchFieldFocused = true
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                    Divider()
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(filteredTasks) { task in
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
                }
                .frame(minWidth: 250)
                .onAppear {
                    isSearchFieldFocused = true
                    
                    if selectedTask == nil && !filteredTasks.isEmpty {
                        selectedTask = filteredTasks.first
                    }
                    
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
        .onChange(of: searchText) { _, _ in
            if let selected = selectedTask, !filteredTasks.contains(where: { $0.id == selected.id }) {
                selectedTask = filteredTasks.first
            }
        }
    }
}
