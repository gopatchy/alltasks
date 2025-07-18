import SwiftUI
import SwiftData

struct OneModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todos: [TodoItem]
    @State private var currentTodoIndex = 0
    @FocusState private var isOneModeViewFocused: Bool
    @Binding var selectedTodo: TodoItem?
    
    var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }
    
    var body: some View {
        VStack {
            if let todo = selectedTodo {
                VStack(spacing: 30) {
                    HStack(alignment: .center, spacing: 20) {
                        VStack {
                            Button(action: previousTask) {
                                Image(systemName: "chevron.left")
                                    .font(.title)
                            }
                            .keyboardShortcut(.leftArrow, modifiers: [])
                            
                            Button(action: {
                                currentTodoIndex = 0
                            }) {
                                Image(systemName: "chevron.left.2")
                                    .font(.title2)
                            }
                            .disabled(currentTodoIndex == 0)
                            .keyboardShortcut("1", modifiers: [])
                        }
                        
                        TaskDetailCard(todo: todo, isEditable: false)
                        .frame(maxWidth: 600)
                        .padding()
                        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                        
                        VStack {
                            Button(action: nextTask) {
                                Image(systemName: "chevron.right")
                                    .font(.title)
                            }
                            .keyboardShortcut(.rightArrow, modifiers: [])
                            
                            Button(action: {
                                currentTodoIndex = incompleteTodos.count - 1
                            }) {
                                Image(systemName: "chevron.right.2")
                                    .font(.title2)
                            }
                            .disabled(currentTodoIndex == incompleteTodos.count - 1)
                            .keyboardShortcut("2", modifiers: [])
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No active tasks")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Text("Add some tasks to get started")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onKeyPress(.leftArrow) {
            previousTask()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            nextTask()
            return .handled
        }
        .onAppear {
            // If we have a selected todo, find its index
            if let todo = selectedTodo,
               let index = incompleteTodos.firstIndex(where: { $0.id == todo.id }) {
                currentTodoIndex = index
            }
            updateCurrentTodo()
        }
        .onChange(of: incompleteTodos) { _, _ in
            updateCurrentTodo()
        }
        .focused($isOneModeViewFocused)
    }
    
    private func nextTask() {
        if currentTodoIndex < incompleteTodos.count - 1 {
            currentTodoIndex += 1
        } else {
            currentTodoIndex = 0
        }
        updateCurrentTodo()
    }
    
    private func previousTask() {
        if currentTodoIndex > 0 {
            currentTodoIndex -= 1
        } else {
            currentTodoIndex = incompleteTodos.count - 1
        }
        updateCurrentTodo()
    }
    
    private func updateCurrentTodo() {
        guard !incompleteTodos.isEmpty else {
            selectedTodo = nil
            return
        }
        
        // Ensure index is valid
        currentTodoIndex = currentTodoIndex % incompleteTodos.count
        selectedTodo = incompleteTodos[currentTodoIndex]
    }
}