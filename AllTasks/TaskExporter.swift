import Foundation
import SwiftData
import AppKit
import UniformTypeIdentifiers

class TaskExporter {
    static func exportTasks(_ tasks: [TaskItem]) {
        // Encode to JSONL (one JSON object per line)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            var jsonlData = Data()
            
            for task in tasks {
                let jsonData = try encoder.encode(task)
                jsonlData.append(jsonData)
                jsonlData.append("\n".data(using: .utf8)!)
            }
            
            // Show save panel
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType(filenameExtension: "jsonl")].compactMap { $0 }
            savePanel.nameFieldStringValue = "alltasks-export-\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")).jsonl"
            savePanel.message = "Export tasks to JSONL file"
            
            if savePanel.runModal() == .OK {
                if let url = savePanel.url {
                    try jsonlData.write(to: url)
                    
                    // Show success alert
                    let alert = NSAlert()
                    alert.messageText = "Export Successful"
                    alert.informativeText = "Exported \(tasks.count) tasks."
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        } catch {
            // Show error alert
            let alert = NSAlert()
            alert.messageText = "Export Failed"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}