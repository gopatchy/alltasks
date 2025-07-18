import SwiftUI
import SwiftData

struct TaskDetailCard: View {
    let task: TaskItem
    var isEditable: Bool = true
    var focusTitleOnAppear: Bool = false
    @State private var editedTitle: String = ""
    @State private var editedDetails: String = ""
    @State private var isEditMode: Bool = false
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var detailsFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack {
                    Button(action: {
                        task.isCompleted.toggle()
                    }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .purple : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    if isEditable || isEditMode {
                        TextField("Task title", text: $editedTitle)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .focused($titleFieldFocused)
                            .onChange(of: editedTitle) { _, newValue in
                                task.title = newValue
                            }
                    } else {
                        Text(task.title)
                            .font(.body)
                            .strikethrough(task.isCompleted)
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
            
            TextEditor(text: isEditable || isEditMode ? $editedDetails : .constant(task.details))
                .font(.body)
                .padding(8)
                .frame(minHeight: 100)
                .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: (isEditable || isEditMode) ? 1 : 0)
                )
                .allowsHitTesting(isEditable || isEditMode)
                .tint((isEditable || isEditMode) ? .primary : .clear)
                .focused($detailsFieldFocused)
                .onChange(of: editedDetails) { _, newValue in
                    if isEditable || isEditMode {
                        task.details = newValue
                    }
                }
            
            Spacer()
        }
        .padding()
        .onAppear {
            editedTitle = task.title
            editedDetails = task.details
            if focusTitleOnAppear && (isEditable || isEditMode) {
                Task { @MainActor in
                    titleFieldFocused = true
                }
            }
        }
        .onChange(of: task) { _, _ in
            editedTitle = task.title
            editedDetails = task.details
            isEditMode = false
        }
        .onChange(of: isEditMode) { _, newValue in
            if newValue {
                // Entering edit mode: ensure details field doesn't steal focus
                detailsFieldFocused = false
                // Use Task with @MainActor for better integration
                Task { @MainActor in
                    titleFieldFocused = true
                }
            } else {
                // Exiting edit mode: clear all focus
                titleFieldFocused = false
                detailsFieldFocused = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .editTask)) { _ in
            if !isEditable {
                // Toggle edit mode for read-only cards
                isEditMode.toggle()
                if !isEditMode {
                    // Post a notification to refocus the parent view when exiting edit mode
                    Task { @MainActor in
                        NotificationCenter.default.post(name: .refocusParentView, object: nil)
                    }
                }
            } else {
                // For always-editable cards, just focus/unfocus the title
                titleFieldFocused.toggle()
            }
        }
    }
}
