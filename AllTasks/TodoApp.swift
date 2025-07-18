import SwiftUI
import SwiftData
import AppKit

extension Notification.Name {
    static let createNewTask = Notification.Name("createNewTask")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct TodoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @FocusedValue(\.selectedTask) var selectedTask: Binding<TodoItem?>?
    @FocusedValue(\.addTaskAction) var addTaskAction: (() -> Void)?
    @FocusedValue(\.focusListAction) var focusListAction: (() -> Void)?
    @State private var selectedMode: ViewMode = .addTask
    
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
            CommandGroup(replacing: .newItem) {
                // Removes New Window menu item
            }
            CommandGroup(replacing: .saveItem) {
                // Keeps other File menu items but removes Close
            }
            CommandMenu("View") {
                Button("New") {
                    // If already in add task mode, create a new task
                    if selectedMode == .addTask {
                        NotificationCenter.default.post(name: .createNewTask, object: nil)
                    } else {
                        selectedMode = .addTask
                    }
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("List") {
                    selectedMode = .list
                    focusListAction?()
                }
                .keyboardShortcut("l", modifiers: .command)
                
                Button("One") {
                    selectedMode = .focus
                }
                .keyboardShortcut("o", modifiers: .command)
                
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
                .disabled(selectedTask?.wrappedValue == nil)
            }
        }
    }
}
