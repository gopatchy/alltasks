import Foundation
import SwiftData

@Model
final class TodoItem {
    var id = UUID()
    var title: String
    var details: String = ""
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    
    init(title: String, details: String = "", isCompleted: Bool = false) {
        self.title = title
        self.details = details
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}