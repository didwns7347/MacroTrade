import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
}

enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}
