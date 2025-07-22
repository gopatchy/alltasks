import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var taskItems: [TaskItem]
    @Query private var comparisons: [Comparison]
    @Binding var selectedMode: ViewMode
    @Binding var selectedTask: TaskItem?
    @Binding var taskFilter: TaskFilter
    @State private var searchText = ""
    @State private var editing = false
    @State private var tasks: [TaskItem] = []
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
                        tasks: $tasks,
                        selectedTask: $selectedTask,
                        editing: $editing
                    )
                case .addTask:
                    NewModeView(
                        tasks: $tasks,
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
            updateTasks()
            selectedTask = tasks.first
        }
        .onChange(of: selectedMode) { _, newMode in
            focused = true
            editing = false
        }
        .onChange(of: taskItems) { _, _ in
            updateTasks()
        }
        .onChange(of: selectedTask) { _, newTask in
            if newTask == nil {
                selectedTask = tasks.first
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
    
    private func updateTasks() {
        var taskMap: [UUID : TaskItem] = [:]
        var iter: TaskItem?
        
        for task in taskItems {
            taskMap[task.id] = task

            if task.previousID == nil {
                if let iter2 = iter {
                    print("multiple first tasks: \(iter2) vs \(task)")
                }
                
                iter = task
            }
        }

        tasks.removeAll()
        
        while let iter2 = iter {
            tasks.append(iter2)
            
            if let nextID = iter2.nextID {
                iter = taskMap[nextID]
            } else {
                iter = nil
            }
        }
    }
    
    private func selectPreviousTask() {
        guard !tasks.isEmpty else { return }
        
        if let currentTask = selectedTask,
           let currentIndex = tasks.firstIndex(where: { $0.id == currentTask.id }) {
            let newIndex = (currentIndex - 1) % tasks.count
            let wrappedIndex = newIndex < 0 ? newIndex + tasks.count : newIndex
            selectedTask = tasks[wrappedIndex]
        } else {
            selectedTask = tasks.first
        }
    }
    
    private func selectNextTask() {
        guard !tasks.isEmpty else { return }
        
        if let currentTask = selectedTask,
           let currentIndex = tasks.firstIndex(where: { $0.id == currentTask.id }) {
            let newIndex = (currentIndex + 1) % tasks.count
            let wrappedIndex = newIndex < 0 ? newIndex + tasks.count : newIndex
            selectedTask = tasks[wrappedIndex]
        } else {
            selectedTask = tasks.first
        }
    }
}
