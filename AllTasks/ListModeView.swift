import SwiftUI
import SwiftData

struct ListModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todos: [TodoItem]
    @Binding var selectedTodo: TodoItem?
    @FocusState var isFocused: Bool
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(todos) { todo in
                            HStack {
                                Button(action: {
                                    todo.isCompleted.toggle()
                                }) {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todo.isCompleted ? .purple : .gray)
                                        .font(.title3)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Text(todo.title)
                                    .strikethrough(todo.isCompleted)
                                    .foregroundColor(todo.isCompleted ? .gray : .primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTodo?.id == todo.id ? Color.accentColor.opacity(0.1) : Color.clear)
                            )
                            .onTapGesture {
                                selectedTodo = todo
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .focusable()
                .focused($isFocused)
                .focusEffectDisabled()
                .onKeyPress(.downArrow) {
                    selectNextTodo()
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    selectPreviousTodo()
                    return .handled
                }
            }
            .frame(minWidth: 250)
            
            VStack {
                if let todo = selectedTodo {
                    TaskDetailCard(todo: todo, isEditable: false)
                        .padding()
                        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                        .padding()
                } else {
                    Text("Select a task to view details")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth: 300)
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private func selectNextTodo() {
        guard let currentTodo = selectedTodo,
              let currentIndex = todos.firstIndex(where: { $0.id == currentTodo.id }),
              currentIndex < todos.count - 1 else { return }
        
        selectedTodo = todos[currentIndex + 1]
    }
    
    private func selectPreviousTodo() {
        guard let currentTodo = selectedTodo,
              let currentIndex = todos.firstIndex(where: { $0.id == currentTodo.id }),
              currentIndex > 0 else { return }
        
        selectedTodo = todos[currentIndex - 1]
    }
}
