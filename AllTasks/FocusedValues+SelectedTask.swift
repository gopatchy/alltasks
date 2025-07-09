import SwiftUI

struct SelectedTaskKey: FocusedValueKey {
    typealias Value = Binding<TodoItem?>
}

extension FocusedValues {
    var selectedTask: Binding<TodoItem?>? {
        get { self[SelectedTaskKey.self] }
        set { self[SelectedTaskKey.self] = newValue }
    }
}