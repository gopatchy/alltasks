import Foundation

enum TaskFilter: String, CaseIterable {
    case incomplete = "Incomplete"
    case all = "All"
    case complete = "Complete"
    
    var systemImage: String {
        switch self {
        case .incomplete:
            return "circle"
        case .all:
            return "asterisk.circle"
        case .complete:
            return "checkmark.circle"
        }
    }
}