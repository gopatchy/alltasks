import SwiftUI
import SwiftData
import AppKit

extension Notification.Name {
    static let editTask = Notification.Name("editTask")
    static let findTask = Notification.Name("findTask")
    static let newTask = Notification.Name("newTask")
    static let releaseFocus = Notification.Name("releaseFocus")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct TaskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var selectedTask: TaskItem? = nil
    @State private var selectedMode: ViewMode = .addTask
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            Comparison.self,
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
            ContentView(
                selectedMode: $selectedMode,
                selectedTask: $selectedTask
            )
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
                Button("Export...") {
                    // Fetch all tasks from the model context
                    let context = sharedModelContainer.mainContext
                    let descriptor = FetchDescriptor<TaskItem>()
                    
                    do {
                        let tasks = try context.fetch(descriptor)
                        TaskExporter.exportTasks(tasks)
                    } catch {
                        print("Failed to fetch tasks: \(error)")
                    }
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
            CommandMenu("Mode") {
                Button("New") {
                    selectedMode = .addTask
                    NotificationCenter.default.post(name: .newTask, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("List") {
                    selectedMode = .list
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
                Button("Edit") {
                    NotificationCenter.default.post(name: .editTask, object: nil)
                }
                .keyboardShortcut("e", modifiers: .command)
                
                Button("Find") {
                    NotificationCenter.default.post(name: .findTask, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Divider()
                
                Button("Delete") {
                    guard let task = selectedTask else {
                        return
                    }
                    guard let context = task.modelContext else {
                        return
                    }
                    context.delete(task)
                    selectedTask = nil
                }
                .disabled(selectedTask == nil)
            }
        }
    }
}
