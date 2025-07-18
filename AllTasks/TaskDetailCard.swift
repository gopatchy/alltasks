import SwiftUI
import SwiftData

struct TaskDetailCard: View {
    let todo: TodoItem
    var isEditable: Bool = true
    var focusTitleOnAppear: Bool = false
    @State private var editedTitle: String = ""
    @State private var editedDetails: String = ""
    @State private var isEditMode: Bool = false
    @FocusState private var titleFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack {
                    Button(action: {
                        todo.isCompleted.toggle()
                    }) {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(todo.isCompleted ? .purple : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    if isEditable || isEditMode {
                        TextField("Task title", text: $editedTitle)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .focused($titleFieldFocused)
                            .onChange(of: editedTitle) { _, newValue in
                                todo.title = newValue
                            }
                    } else {
                        Text(todo.title)
                            .font(.body)
                            .strikethrough(todo.isCompleted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(8)
                .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: (isEditable || isEditMode) ? 1 : 0)
                )
                
                Spacer()
                
                if !isEditable {
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title)
                            .foregroundColor(isEditMode ? .accentColor : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            TextEditor(text: isEditable || isEditMode ? $editedDetails : .constant(todo.details))
                .font(.body)
                .padding(8)
                .frame(minHeight: 100)
                .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: (isEditable || isEditMode) ? 1 : 0)
                )
                .allowsHitTesting(isEditable || isEditMode)
                .onChange(of: editedDetails) { _, newValue in
                    if isEditable || isEditMode {
                        todo.details = newValue
                    }
                }
            
            Spacer()
        }
        .padding()
        .onAppear {
            editedTitle = todo.title
            editedDetails = todo.details
            if focusTitleOnAppear && (isEditable || isEditMode) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    titleFieldFocused = true
                }
            }
        }
        .onChange(of: todo) { _, _ in
            editedTitle = todo.title
            editedDetails = todo.details
            isEditMode = false
        }
    }
}
