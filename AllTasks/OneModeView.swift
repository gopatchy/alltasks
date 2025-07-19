import SwiftUI
import SwiftData

struct OneModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTask: TaskItem?
    @Binding var wantTaskOffset: Int
    
    var body: some View {
        VStack {
            if let task = selectedTask {
                VStack(spacing: 30) {
                    HStack(alignment: .center, spacing: 20) {
                        Button(action: {
                            wantTaskOffset -= 1
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .glassEffect(in: Circle())
                        
                        TaskDetailCard(task: task, isEditable: false)
                            .frame(maxWidth: 600)
                            .padding()
                            .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                        
                        Button(action: {
                            wantTaskOffset += 1
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .glassEffect(in: Circle())
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
    }
}
