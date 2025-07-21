import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @Binding var selectedMode: ViewMode
    @Binding var selectedTask: TaskItem?
    @State private var searchText = ""
    @State private var editing = false
    @State private var taskFilter: TaskFilter = .incomplete
    @FocusState private var focused: Bool
    @FocusState private var searchFocused: Bool
    
    var sortedTasks: [TaskItem] {
        let sorted = TaskSorter.sortTasks(tasks, using: comparisons)
        switch taskFilter {
        case .incomplete:
            return sorted.filter { !$0.isCompleted }
        case .all:
            return sorted
        case .complete:
            return sorted.filter { $0.isCompleted }
        }
    }
    
    var incompleteTasks: [TaskItem] {
        return sortedTasks.filter { !$0.isCompleted }
    }
    
    var filteredTasks: [TaskItem] {
        let sorted = sortedTasks
        if searchText.isEmpty {
            return sorted
        } else {
            return sorted.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.details.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                taskFilter: $taskFilter,
                searchText: $searchText,
                isSearchFieldFocused: $searchFocused,
                selectedMode: $selectedMode,
                filteredTasks: filteredTasks,
                selectedTask: $selectedTask
            )
            
            Divider()
            
            Group {
                switch selectedMode {
                case .list:
                    ListModeView(
                        selectedTask: $selectedTask,
                        sortedTasks: searchText.isEmpty ? sortedTasks : filteredTasks,
                        editing: $editing
                    )
                case .addTask:
                    NewModeView(
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
        }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onAppear {
            focused = true
            selectedTask = sortedTasks.first
        }
        .onChange(of: selectedMode) { _, newMode in
            focused = true
            editing = false
        }
        .onChange(of: selectedTask) { _, newTask in
            if newTask == nil {
                let taskList = getTaskList()
                selectedTask = taskList.first
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
    
    private func getTaskList() -> [TaskItem] {
        switch selectedMode {
        case .list:
            return searchText.isEmpty ? sortedTasks : filteredTasks
        case .focus:
            return incompleteTasks
        default:
            return []
        }
    }
    
    private func selectPreviousTask() {
        let taskList = getTaskList()
        guard !taskList.isEmpty else { return }
        
        if let currentTask = selectedTask,
           let currentIndex = taskList.firstIndex(where: { $0.id == currentTask.id }) {
            let newIndex = (currentIndex - 1) % taskList.count
            let wrappedIndex = newIndex < 0 ? newIndex + taskList.count : newIndex
            selectedTask = taskList[wrappedIndex]
        } else {
            selectedTask = taskList.first
        }
    }
    
    private func selectNextTask() {
        let taskList = getTaskList()
        guard !taskList.isEmpty else { return }
        
        if let currentTask = selectedTask,
           let currentIndex = taskList.firstIndex(where: { $0.id == currentTask.id }) {
            let newIndex = (currentIndex + 1) % taskList.count
            let wrappedIndex = newIndex < 0 ? newIndex + taskList.count : newIndex
            selectedTask = taskList[wrappedIndex]
        } else {
            selectedTask = taskList.first
        }
    }
}
