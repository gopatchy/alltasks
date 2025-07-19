import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @Binding var selectedMode: ViewMode
    @State private var selectedTask: TaskItem?
    @State private var searchText = ""
    @FocusState private var focused: Bool
    
    var sortedTasks: [TaskItem] {
        TaskSorter.sortTasks(tasks, using: comparisons)
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
                    OneModeView(selectedTask: $selectedTask)
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
        }
        .onChange(of: selectedMode) { _, _ in
            focused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .clearAndFocusSearch)) { _ in
            if selectedMode == .find {
                searchText = ""
            }
        }
        .onKeyPress(.upArrow) {
            selectPreviousTask()
            return .handled
        }
        .onKeyPress(.downArrow) {
            selectNextTask()
            return .handled
        }
    }
    
    private func getTaskList() -> [TaskItem] {
        switch selectedMode {
        case .list:
            return sortedTasks
        case .find:
            return filteredTasks
        default:
            return []
        }
    }
    
    private func selectNextTask() {
        let taskList = getTaskList()
        guard let currentTask = selectedTask,
              let currentIndex = taskList.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex < taskList.count - 1 else { return }
        
        selectedTask = taskList[currentIndex + 1]
    }
    
    private func selectPreviousTask() {
        let taskList = getTaskList()
        guard let currentTask = selectedTask,
              let currentIndex = taskList.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex > 0 else { return }
        
        selectedTask = taskList[currentIndex - 1]
    }
}
