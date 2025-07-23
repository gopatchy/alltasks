import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var comparisons: [Comparison] // TODO: Remove
    @Binding var modeSelected: ViewMode
    
    @Query private var tasks: [TaskItem]
    @State private var tasksSorted = TasksSorted()
    @State private var tasksFiltered = TasksFiltered()
    @Binding var taskFilter: TaskFilter
    @Binding var taskSelected: TaskItem?

    @State private var searchText = ""
    @FocusState private var searchFocused: Bool
    
    @State private var editing = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                taskFilter: $taskFilter,
                searchText: $searchText,
                searchFocused: $searchFocused,
                modeSelected: $modeSelected
            )
            
            Divider()
            
            Group {
                switch modeSelected {
                case .list:
                    ListModeView(
                        tasksFiltered: $tasksFiltered,
                        taskSelected: $taskSelected,
                        editing: $editing
                    )
                case .addTask:
                    NewModeView(
                        tasksSorted: $tasksSorted,
                        editing: $editing
                    )
                case .focus:
                    OneModeView(
                        taskSelected: $taskSelected,
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
        .onChange(of: modeSelected) { _, newMode in
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
            if let task = tasksFiltered.first(where: { $0.id == taskSelected?.id }) {
                taskSelected = task
            } else {
                taskSelected = tasksFiltered.first
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
        if let prevTask = taskSelected?.prevTask {
            taskSelected = prevTask
        } else {
            taskSelected = tasksFiltered.last
        }
    }
    
    private func selectNextTask() {
        if let nextTask = taskSelected?.nextTask {
            taskSelected = nextTask
        } else {
            taskSelected = tasksFiltered.first
        }
    }
}
