import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @Binding var selectedMode: ViewMode
    @Binding var selectedTask: TaskItem?
    @Binding var taskFilter: TaskFilter
    @State private var searchText = ""
    @State private var editing = false
    @State private var tasksSorted = TasksSorted()
    @State private var tasksFiltered = TasksFiltered()
    @FocusState private var focused: Bool
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                taskFilter: $taskFilter,
                searchText: $searchText,
                searchFocused: $searchFocused,
                selectedMode: $selectedMode
            )
            
            Divider()
            
            Group {
                switch selectedMode {
                case .list:
                    ListModeView(
                        tasksFiltered: $tasksFiltered,
                        selectedTask: $selectedTask,
                        editing: $editing
                    )
                case .addTask:
                    NewModeView(
                        tasksSorted: $tasksSorted,
                        editing: $editing
                    )
                case .focus:
                    OneModeView(
                        selectedTask: $selectedTask,
                        editing: $editing
                    )
                case .prioritize:
                    PrioritizeModeView(
                        editing: $editing
                    )
                }
            }
            .focusable()
            .focusEffectDisabled()
        }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onAppear {
            focused = true
            updateTasksSorted()
        }
        .onChange(of: selectedMode) { _, newMode in
            focused = true
            editing = false
        }
        .onChange(of: tasks) { _, _ in
            updateTasksSorted()
        }
        .onChange(of: tasksSorted) { _, _ in
            updateTasksFiltered()
        }
        .onChange(of: taskFilter) { _, _ in
            updateTasksFiltered()
        }
        .onChange(of: searchText) { _, _ in
            updateTasksFiltered()
        }
        .onChange(of: tasksFiltered) { _, _ in
            if let task = tasksFiltered.first(where: { $0.id == selectedTask?.id }) {
                selectedTask = task
            } else {
                selectedTask = tasksFiltered.first
            }
        }
        .onKeyPress(.upArrow) {
            if editing || searchFocused {
                return .ignored
            }
            
            selectPreviousTask()
            
            return .handled
        }
        .onKeyPress(.downArrow) {
            if editing || searchFocused {
                return .ignored
            }
            
            selectNextTask()
            
            return .handled
        }
        .onKeyPress(.escape) {
            focused = true
            return .handled
        }
        .onReceive(NotificationCenter.default.publisher(for: .releaseFocus)) { _ in
            focused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .findTask)) { _ in
            searchText = ""
            searchFocused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectPrevious)) { _ in
            selectPreviousTask()
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectNext)) { _ in
            selectNextTask()
        }
    }
    
    private func updateTasksSorted() {
        tasksSorted = TasksSorted(tasks: tasks)
    }
    
    private func updateTasksFiltered() {
        tasksFiltered = TasksFiltered(tasksSorted: tasksSorted, taskFilter: taskFilter, searchText: searchText)
    }
    
    private func selectPreviousTask() {
        if let prevTask = selectedTask?.prevTask {
            selectedTask = prevTask
        } else {
            selectedTask = tasksFiltered.last
        }
    }
    
    private func selectNextTask() {
        if let nextTask = selectedTask?.nextTask {
            selectedTask = nextTask
        } else {
            selectedTask = tasksFiltered.first
        }
    }
}
