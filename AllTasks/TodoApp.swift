import SwiftUI
import SwiftData
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct TodoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @FocusedValue(\.selectedTask) var selectedTask: Binding<TodoItem?>?
    @State private var selectedMode: ViewMode = .list
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedMode: $selectedMode)
                .frame(minWidth: 800, minHeight: 600)
                .accentColor(.purple)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Divider()
            }
            CommandMenu("View") {
                Button("List") {
                    selectedMode = .list
                }
                .keyboardShortcut("l", modifiers: .command)
                
                Button("Focus") {
                    selectedMode = .focus
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Button("Prioritize") {
                    selectedMode = .prioritize
                }
                .keyboardShortcut("p", modifiers: .command)
            }
            CommandMenu("Task") {
                Button("Delete") {
                    if let taskBinding = selectedTask,
                       let task = taskBinding.wrappedValue {
                        if let context = task.modelContext {
                            context.delete(task)
                            taskBinding.wrappedValue = nil
                        }
                    }
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selectedTask?.wrappedValue == nil)
            }
        }
    }
}
