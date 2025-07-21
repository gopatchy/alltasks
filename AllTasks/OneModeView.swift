import SwiftUI
import SwiftData

struct OneModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTask: TaskItem?
    @Binding var wantTaskOffset: Int
    @Binding var editing: Bool
    
    var body: some View {
        VStack {
            if let task = selectedTask {
                HStack(spacing: 20) {
                    TaskDetailCard(task: task, editing: $editing)
                        .frame(maxWidth: 600)
                        .padding()
                        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            wantTaskOffset -= 1
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.title)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .glassEffect(in: Circle())
                        
                        Button(action: {
                            wantTaskOffset += 1
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .glassEffect(in: Circle())
                    }
                }
                .frame(maxWidth: .infinity)
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
