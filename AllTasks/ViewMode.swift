import Foundation

enum ViewMode: String, CaseIterable {
    case new = "New"
    case list = "List"
    case one = "One"
    case prioritize = "Prioritize"
    
    var systemImage: String {
        switch self {
        case .new:
            return "plus.circle"
        case .list:
            return "list.bullet"
        case .one:
            return "target"
        case .prioritize:
            return "arrow.up.arrow.down"
        }
    }
}
