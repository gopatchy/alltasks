import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedMode: ViewMode
    @State private var selectedTask: TaskItem?
    @FocusState private var isListFocused: Bool
    @FocusState private var isFindFocused: Bool
    @FocusState private var isTaskListViewFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
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
                        isFocused: _isListFocused
                    )
                case .find:
                    FindModeView(
                        selectedTask: $selectedTask,
                        isFocused: _isFindFocused
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
        .focusedValue(\.selectedTask, $selectedTask)
        .focusedValue(\.focusListAction) {
            isListFocused = true
        }
        .focused($isTaskListViewFocused)
        .onChange(of: selectedMode) { oldValue, newValue in
            if newValue == .list {
                // Ensure list gets focus when switching to list mode
                Task { @MainActor in
                    isListFocused = true
                }
            } else if newValue == .find {
                // Ensure find gets focus when switching to find mode
                Task { @MainActor in
                    isFindFocused = true
                }
            } else if newValue == .focus || newValue == .prioritize {
                // Ensure TaskListView keeps focus in One mode and Prioritize mode
                Task { @MainActor in
                    isTaskListViewFocused = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .refocusParentView)) { _ in
            // Refocus TaskListView when edit mode is disabled
            if selectedMode == .list {
                isListFocused = true
            } else if selectedMode == .find {
                isFindFocused = true
            } else if selectedMode == .focus || selectedMode == .prioritize {
                isTaskListViewFocused = true
            }
        }
    }
}
