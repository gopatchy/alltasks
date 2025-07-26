import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var comparisons: [Comparison] // TODO: Remove
    
    @State var modeSelected: ViewMode = .list
    
    @Query private var tasks: [TaskItem]
    @State private var tasksSorted = TasksSorted()
    @State private var tasksFiltered = TasksFiltered()
    @State private var taskFilter: TaskFilter = .incomplete
    @State private var taskSelectedIndex: Int = 0

    @State private var searchText = ""
    @FocusState private var searchFocused: Bool
    
    @State private var editing = false
    @FocusState private var focused: Bool
    
    private var taskSelected: TaskItem? {
        guard taskSelectedIndex < tasksFiltered.count else {
            return nil
        }
        
        return tasksFiltered[taskSelectedIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                taskFilter: $taskFilter,
                searchText: $searchText,
                searchFocused: $searchFocused,
                modeSelected: $modeSelected
            )
            
            Divider()
            
            ModeView(
                modeSelected: modeSelected,
                tasksSorted: tasksSorted,
                tasksFiltered: tasksFiltered,
                taskSelected: taskSelected,
                editing: $editing,
            )
        }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onAppear {
            focused = true
            updateTasksSorted()
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

        onChangeView
        onReceiveView
    }
    
    private var onChangeView: some View {
        EmptyView()
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
        .onChange(of: tasksFiltered) { oldTasks, newTasks in
            guard oldTasks.count > 0 else {
                return
            }

            let oldSelected = oldTasks[taskSelectedIndex]

            if let i = newTasks.firstIndex(where: { $0.id == oldSelected.id }) {
                taskSelectedIndex = i
            } else {
                taskSelectedIndex = 0
            }
        }
    }
    
    private var onReceiveView: some View {
        EmptyView()
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
        .onReceive(NotificationCenter.default.publisher(for: .taskSelect)) { notification in
            let task = notification.object as! TaskItem
            if let i = tasksFiltered.firstIndex(where: { $0.id == task.id }) {
                taskSelectedIndex = i
            }
        }
    }
    
    private func updateTasksSorted() {
        tasksSorted = TasksSorted(tasks: tasks)
    }
    
    private func updateTasksFiltered() {
        tasksFiltered = TasksFiltered(tasksSorted: tasksSorted, taskFilter: taskFilter, searchText: searchText)
    }
    
    private func selectPreviousTask() {
        selectTask(offset: -1)
    }
    
    private func selectNextTask() {
        selectTask(offset: 1)
    }
    
    private func selectTask(offset: Int) {
        guard tasksFiltered.count > 0 else {
            return
        }
        
        taskSelectedIndex = (taskSelectedIndex + offset) % tasksFiltered.count
    }
}
