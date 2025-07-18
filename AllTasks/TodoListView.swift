import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedMode: ViewMode
    @State private var selectedTodo: TodoItem?
    @State private var newTodoText: String = ""
    @FocusState private var isAddFieldFocused: Bool
    @FocusState private var isListFocused: Bool
    
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
                        selectedTodo: $selectedTodo,
                        isFocused: _isListFocused
                    )
                case .addTask:
                    NewModeView()
                case .focus:
                    OneModeView(selectedTodo: $selectedTodo)
                case .prioritize:
                    PrioritizeModeView()
                }
            }
            .focusedValue(\.selectedTask, $selectedTodo)
        }
        .focusedValue(\.addTaskAction) {
            isAddFieldFocused = true
        }
        .focusedValue(\.focusListAction) {
            isAddFieldFocused = false
            isListFocused = true
        }
    }
    
    private func addTodo() {
        guard !newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newTodo = TodoItem(title: newTodoText)
        modelContext.insert(newTodo)
        newTodoText = ""
    }
}
