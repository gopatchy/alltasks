import SwiftUI
import SwiftData

struct ModeView: View {
    var modeSelected: ViewMode
    var tasksSorted: TasksSorted
    var tasksFiltered: TasksFiltered
    var taskSelected: TaskItem?
    @Binding var editing: Bool
    
    var body: some View {
        Group {
            switch modeSelected {
            case .list:
                ListModeView(
                    tasksFiltered: tasksFiltered,
                    taskSelected: taskSelected,
                    editing: $editing
                )
            case .new:
                NewModeView(
                    tasksSorted: tasksSorted,
                    editing: $editing
                )
            case .one:
                OneModeView(
                    taskSelected: taskSelected,
                    editing: $editing
                )
            case .prioritize:
                PrioritizeModeView(
                    editing: $editing
                )
            }
        }
        .focusable()
        .focusEffectDisabled()
    }
}
