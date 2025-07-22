import Foundation
import SwiftData

@Model
final class TaskItem: Codable {
    var id = UUID()
    var title: String
    var details: String = ""
    var complete: Bool = false
    var created: Date = Date()
    
    init(title: String, details: String = "", complete: Bool = false) {
        self.title = title
        self.details = details
        self.complete = complete
        self.created = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, details, complete, created
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        details = try container.decode(String.self, forKey: .details)
        complete = try container.decode(Bool.self, forKey: .complete)
        created = try container.decode(Date.self, forKey: .created)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(details, forKey: .details)
        try container.encode(complete, forKey: .complete)
        try container.encode(created, forKey: .created)
    }
}
