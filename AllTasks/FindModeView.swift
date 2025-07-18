import SwiftUI
import SwiftData

struct FindModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Binding var selectedTask: TaskItem?
    @FocusState var isFocused: Bool
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    var filteredTasks: [TaskItem] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.details.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        HSplitView {
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
                                isFocused = true
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
                .onKeyPress(.escape) {
                    searchText = ""
                    isSearchFieldFocused = true
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
            // Focus search field with a small delay to ensure view is rendered
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                isSearchFieldFocused = true
            }
            // Select first filtered task if none selected
            if selectedTask == nil && !filteredTasks.isEmpty {
                selectedTask = filteredTasks.first
            }
        }
        .onChange(of: searchText) { _, _ in
            // Update selected task if current selection is not in filtered results
            if let selected = selectedTask, !filteredTasks.contains(where: { $0.id == selected.id }) {
                selectedTask = filteredTasks.first
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .clearAndFocusSearch)) { _ in
            searchText = ""
            isSearchFieldFocused = true
        }
    }
    
    private func selectNextTask() {
        guard let currentTask = selectedTask,
              let currentIndex = filteredTasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex < filteredTasks.count - 1 else { return }
        
        selectedTask = filteredTasks[currentIndex + 1]
    }
    
    private func selectPreviousTask() {
        guard let currentTask = selectedTask,
              let currentIndex = filteredTasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex > 0 else { return }
        
        selectedTask = filteredTasks[currentIndex - 1]
    }
}
