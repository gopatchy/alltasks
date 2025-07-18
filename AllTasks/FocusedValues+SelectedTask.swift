import SwiftUI

struct SelectedTaskKey: FocusedValueKey {
    typealias Value = Binding<TaskItem?>
}

extension FocusedValues {
    var selectedTask: Binding<TaskItem?>? {
        get { self[SelectedTaskKey.self] }
        set { self[SelectedTaskKey.self] = newValue }
    }
}