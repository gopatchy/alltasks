import SwiftUI
import SwiftData
import AppKit

extension Notification.Name {
    static let modeSet = Notification.Name("modeSet")
    
    static let filterSet = Notification.Name("filterSet")
    static let filterCycle = Notification.Name("filterCycle")
    
    static let taskEdit = Notification.Name("taskEdit")
    static let taskFind = Notification.Name("taskFind")
    static let taskDelete = Notification.Name("taskDelete")
    static let taskPrevious = Notification.Name("taskPrevious")
    static let taskNext = Notification.Name("taskNext")
    
    static let focusRelease = Notification.Name("focusRelease")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct TaskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
            ContentView()
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
                    NotificationCenter.default.post(name: .modeSet, object: ViewMode.new)
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("List") {
                    NotificationCenter.default.post(name: .modeSet, object: ViewMode.list)
                }
                .keyboardShortcut("l", modifiers: .command)
                
                Button("One") {
                    NotificationCenter.default.post(name: .modeSet, object: ViewMode.one)
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Prioritize") {
                    NotificationCenter.default.post(name: .modeSet, object: ViewMode.prioritize)
                }
                .keyboardShortcut("p", modifiers: .command)
            }
            CommandMenu("Filter") {
                Button("Incomplete") {
                    NotificationCenter.default.post(name: .filterSet, object: TaskFilter.incomplete)
                }
                
                Button("All") {
                    NotificationCenter.default.post(name: .filterSet, object: TaskFilter.all)
                }
                
                Button("Complete") {
                    NotificationCenter.default.post(name: .filterSet, object: TaskFilter.complete)
                }
                
                Divider()
                
                Button("Cycle") {
                    NotificationCenter.default.post(name: .filterCycle, object: nil)
                }
                .keyboardShortcut("i", modifiers: .command)
            }
            CommandMenu("Task") {
                Button("Edit") {
                    NotificationCenter.default.post(name: .taskEdit, object: nil)
                }
                .keyboardShortcut("e", modifiers: .command)
                
                Button("Find") {
                    NotificationCenter.default.post(name: .taskFind, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Divider()
                
                Button("Delete") {
                    NotificationCenter.default.post(name: .taskDelete, object: nil)
                }
            }
        }
    }
}
