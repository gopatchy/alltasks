import Foundation
import SwiftData

@Model
final class TaskItem: Codable {
    var id = UUID()
    var title: String
    var details: String = ""
    var complete: Bool = false
    var priority: Int64 = 0
    var created: Date = Date()
    var prevID: UUID?
    var nextID: UUID?
    
    init(title: String, details: String = "", complete: Bool = false, priority: Int64 = 0, previousID: UUID? = nil, nextID: UUID? = nil) {
        self.title = title
        self.details = details
        self.complete = complete
        self.priority = priority
        self.created = Date()
        self.prevID = previousID
        self.nextID = nextID
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, details, complete, priority, created, prevID, nextID
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        details = try container.decode(String.self, forKey: .details)
        complete = try container.decode(Bool.self, forKey: .complete)
        priority = try container.decode(Int64.self, forKey: .priority)
        created = try container.decode(Date.self, forKey: .created)
        prevID = try container.decode(UUID.self, forKey: .prevID)
        nextID = try container.decode(UUID.self, forKey: .nextID)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(details, forKey: .details)
        try container.encode(priority, forKey: .priority)
        try container.encode(complete, forKey: .complete)
        try container.encode(created, forKey: .created)
        try container.encode(prevID, forKey: .prevID)
        try container.encode(nextID, forKey: .nextID)
    }
    
    func matches(taskFilter: TaskFilter, searchText: String) -> Bool {
        switch taskFilter {
        case .incomplete:
            if complete { return false }
        case .complete:
            if !complete { return false }
        case .all:
            break
        }
        
        if !searchText.isEmpty &&
            !title.localizedCaseInsensitiveContains(searchText) &&
            !details.localizedCaseInsensitiveContains(searchText) {
            return false
        }
        
        return true
    }
}
