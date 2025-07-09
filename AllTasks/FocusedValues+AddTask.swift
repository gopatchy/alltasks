import SwiftUI

struct AddTaskActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var addTaskAction: (() -> Void)? {
        get { self[AddTaskActionKey.self] }
        set { self[AddTaskActionKey.self] = newValue }
    }
}