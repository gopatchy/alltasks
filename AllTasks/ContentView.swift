import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var comparisons: [Comparison]
    @Binding var selectedMode: ViewMode
    @State private var selectedTask: TaskItem?
    @FocusState private var focused: Bool
    
    var sortedTasks: [TaskItem] {
        TaskSorter.sortTasks(tasks, using: comparisons)
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
        .onKeyPress(.upArrow) {
            print("upArrow")
            if selectedMode == .list {
                selectPreviousTask()
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.downArrow) {
            print("downArrow")
            if selectedMode == .list {
                selectNextTask()
                return .handled
            }
            return .ignored
        }
    }
    
    private func selectNextTask() {
        guard let currentTask = selectedTask,
              let currentIndex = sortedTasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex < sortedTasks.count - 1 else { return }
        
        selectedTask = sortedTasks[currentIndex + 1]
    }
    
    private func selectPreviousTask() {
        guard let currentTask = selectedTask,
              let currentIndex = sortedTasks.firstIndex(where: { $0.id == currentTask.id }),
              currentIndex > 0 else { return }
        
        selectedTask = sortedTasks[currentIndex - 1]
    }
}
