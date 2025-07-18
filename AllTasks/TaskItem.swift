import Foundation
import SwiftData

@Model
final class TaskItem: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case id, title, details, isCompleted, createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        details = try container.decode(String.self, forKey: .details)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(details, forKey: .details)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(createdAt, forKey: .createdAt)
    }
}