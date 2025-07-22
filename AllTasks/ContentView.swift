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
    @State private var tasks = Tasks()
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
                        tasks: .constant(tasks.filter(by: taskFilter, searchText: searchText)),
                        selectedTask: $selectedTask,
                        editing: $editing
                    )
                case .addTask:
                    NewModeView(
                        tasks: .constant(tasks.tasks),
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
            tasks.update(from: taskItems)
            selectedTask = tasks.tasks.first
        }
        .onChange(of: selectedMode) { _, newMode in
            focused = true
            editing = false
        }
        .onChange(of: taskItems) { _, _ in
            tasks.update(from: taskItems)
        }
        .onChange(of: selectedTask) { _, newTask in
            if newTask == nil {
                selectedTask = tasks.tasks.first
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
    
    private func selectPreviousTask() {
        selectedTask = tasks.selectPrevious(from: selectedTask)
    }
    
    private func selectNextTask() {
        selectedTask = tasks.selectNext(from: selectedTask)
    }
}
