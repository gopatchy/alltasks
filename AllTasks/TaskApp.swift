import SwiftUI
import SwiftData
import AppKit

extension Notification.Name {
    static let createNewTask = Notification.Name("createNewTask")
    static let editTask = Notification.Name("editTask")
    static let refocusParentView = Notification.Name("refocusParentView")
    static let clearAndFocusSearch = Notification.Name("clearAndFocusSearch")
    static let restartPrioritization = Notification.Name("restartPrioritization")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct TaskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @FocusedValue(\.selectedTask) var selectedTask: Binding<TaskItem?>?
    @FocusedValue(\.focusListAction) var focusListAction: (() -> Void)?
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
                Button("Export Tasks...") {
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
                
                Button("Find") {
                    if selectedMode == .find {
                        NotificationCenter.default.post(name: .clearAndFocusSearch, object: nil)
                    } else {
                        selectedMode = .find
                    }
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Button("One") {
                    selectedMode = .focus
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Prioritize") {
                    if selectedMode == .prioritize {
                        NotificationCenter.default.post(name: .restartPrioritization, object: nil)
                    } else {
                        selectedMode = .prioritize
                    }
                }
                .keyboardShortcut("p", modifiers: .command)
            }
            CommandMenu("Task") {
                Button("Edit") {
                    NotificationCenter.default.post(name: .editTask, object: nil)
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(selectedTask?.wrappedValue == nil || selectedMode == .prioritize)
                
                Divider()
                
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
