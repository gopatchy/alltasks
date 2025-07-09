import Foundation

enum ViewMode: String, CaseIterable {
    case list = "List"
    case focus = "Focus"
    case prioritize = "Prioritize"
    
    var systemImage: String {
        switch self {
        case .list:
            return "list.bullet"
        case .prioritize:
            return "arrow.up.arrow.down"
        case .focus:
            return "target"
        }
    }
}