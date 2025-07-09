import SwiftUI

struct FocusListActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var focusListAction: (() -> Void)? {
        get { self[FocusListActionKey.self] }
        set { self[FocusListActionKey.self] = newValue }
    }
}