import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var comparisons: [Comparison] // TODO: Remove
    
    @State var modeSelected: ViewMode = .list
    
    @Query private var tasks: [TaskItem]
    @State private var tasksSorted = TasksSorted()
    @State private var tasksFiltered = TasksFiltered()
    @State var taskFilter: TaskFilter = .incomplete
    @State var taskSelected: TaskItem? = nil

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
                case .new:
                    NewModeView(
                        tasksSorted: $tasksSorted,
                        editing: $editing
                    )
                case .one:
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
        
        .onReceive(NotificationCenter.default.publisher(for: .focusRelease)) { _ in
            focused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .modeSet)) { notification in
            modeSelected = notification.object as! ViewMode
        }
        .onReceive(NotificationCenter.default.publisher(for: .filterSet)) { notification in
            taskFilter = notification.object as! TaskFilter
        }
        .onReceive(NotificationCenter.default.publisher(for: .filterCycle)) { _ in
            switch taskFilter {
            case .incomplete:
                taskFilter = .all
            case .all:
                taskFilter = .complete
            case .complete:
                taskFilter = .incomplete
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskFind)) { _ in
            searchText = ""
            searchFocused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskPrevious)) { _ in
            selectPreviousTask()
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskNext)) { _ in
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
