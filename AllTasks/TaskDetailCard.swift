import SwiftUI
import SwiftData

struct TaskDetailCard: View {
    let task: TaskItem
    @Binding var editing: Bool
    var focusTitleOnAppear: Bool = false
    var releaseFocus: Bool = true
    @State private var editedTitle: String = ""
    @State private var editedDetails: String = ""
    @FocusState private var titleFocused: Bool
    @FocusState private var detailsFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack {
                    Button(action: {
                        task.complete.toggle()
                    }) {
                        Image(systemName: task.complete ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.complete ? .purple : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    TextField("Task title", text: $editedTitle)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($titleFocused)
                        .onChange(of: editedTitle) { _, newValue in
                            task.title = newValue
                        }
                }
                .padding(8)
                .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: titleFocused || detailsFocused ? 1 : 0)
                )
            }
            
            TextEditor(text: $editedDetails)
                .font(.body)
                .padding(8)
                .frame(minHeight: 100)
                .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: titleFocused || detailsFocused ? 1 : 0)
                )
                .tint(.primary)
                .focused($detailsFocused)
                .onChange(of: editedDetails) { _, newValue in
                    task.details = newValue
                }
            
            Spacer()
        }
        .padding()
        .onAppear {
            editedTitle = task.title
            editedDetails = task.details
            if focusTitleOnAppear {
                Task { @MainActor in
                    titleFocused = true
                }
            }
        }
        .onChange(of: task) { _, _ in
            editedTitle = task.title
            editedDetails = task.details
        }
        .onChange(of: titleFocused) {
            editing = titleFocused
        }
        .onChange(of: detailsFocused) {
            editing = detailsFocused
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskEdit)) { _ in
            if releaseFocus && (titleFocused || detailsFocused) {
                NotificationCenter.default.post(name: .focusRelease, object: nil)
            } else {
                titleFocused = true
            }
        }
    }
}
