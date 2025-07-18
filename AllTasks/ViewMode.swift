import Foundation

enum ViewMode: String, CaseIterable {
    case addTask = "Add"
    case list = "List"
    case find = "Find"
    case focus = "Focus"
    case prioritize = "Prioritize"
    
    var systemImage: String {
        switch self {
        case .addTask:
            return "plus.circle"
        case .list:
            return "list.bullet"
        case .find:
            return "magnifyingglass"
        case .focus:
            return "target"
        case .prioritize:
            return "arrow.up.arrow.down"
        }
    }
}