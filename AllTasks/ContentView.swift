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
                        selectedTask: $selectedTask,
                        sortedTasks: getTaskList(),
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
            // Allow focus to leave search bar
            .focusable()
            .focusEffectDisabled()
        }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onAppear {
            focused = true
            selectedTask = getTaskList().first
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
        return tasks
            .filter { task in
                searchText == "" ||
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.details.localizedCaseInsensitiveContains(searchText)
            }
            .filter { task in
                taskFilter == .all ||
                (taskFilter == .incomplete && !task.complete) ||
                (taskFilter == .complete && task.complete)
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
