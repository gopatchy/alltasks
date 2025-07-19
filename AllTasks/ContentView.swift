import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @Binding var selectedMode: ViewMode
    @State private var selectedTask: TaskItem?
    @State private var searchText = ""
    @State private var wantTaskOffset = 0
    @FocusState private var focused: Bool
    
    var sortedTasks: [TaskItem] {
        TaskSorter.sortTasks(tasks, using: comparisons)
    }
    
    var incompleteTasks: [TaskItem] {
        let incomplete = tasks.filter { !$0.isCompleted }
        return TaskSorter.sortTasks(incomplete, using: comparisons)
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
            HStack {
                ModeSwitcher(selectedMode: $selectedMode)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            Group {
                switch selectedMode {
                case .list:
                    ListModeView(
                        selectedTask: $selectedTask,
                        sortedTasks: sortedTasks
                    )
                case .find:
                    FindModeView(
                        selectedTask: $selectedTask,
                        searchText: $searchText,
                        filteredTasks: filteredTasks
                    )
                case .addTask:
                    NewModeView()
                case .focus:
                    OneModeView(selectedTask: $selectedTask, wantTaskOffset: $wantTaskOffset)
                case .prioritize:
                    PrioritizeModeView()
                }
            }
        }
        .focused($focused)
        .focusable()
        .focusEffectDisabled()
        .onAppear {
            focused = true
            selectedTask = sortedTasks.first
        }
        .onChange(of: selectedMode) { _, newMode in
            focused = true
        }
        .onChange(of: selectedTask) { _, newTask in
            if newTask == nil {
                let taskList = getTaskList()
                selectedTask = taskList.first
            }
        }
        .onChange(of: wantTaskOffset) { _, _ in
            let taskList = getTaskList()
            guard !taskList.isEmpty else { return }
            
            if let currentTask = selectedTask,
               let currentIndex = taskList.firstIndex(where: { $0.id == currentTask.id }) {
                let newIndex = (currentIndex + wantTaskOffset) % taskList.count
                let wrappedIndex = newIndex < 0 ? newIndex + taskList.count : newIndex
                selectedTask = taskList[wrappedIndex]
            } else {
                selectedTask = taskList.first
            }
            
            wantTaskOffset = 0
        }
        .onKeyPress(.upArrow) {
            wantTaskOffset -= 1
            return .handled
        }
        .onKeyPress(.downArrow) {
            wantTaskOffset += 1
            return .handled
        }
        .onKeyPress(.leftArrow) {
            wantTaskOffset -= 1
            return .handled
        }
        .onKeyPress(.rightArrow) {
            wantTaskOffset += 1
            return .handled
        }
    }
    
    private func getTaskList() -> [TaskItem] {
        switch selectedMode {
        case .list:
            return sortedTasks
        case .find:
            return filteredTasks
        case .focus:
            return incompleteTasks
        default:
            return []
        }
    }
    
}
