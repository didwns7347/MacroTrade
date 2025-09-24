import Foundation

struct OpenAIRequest: Codable {
    let model: String
    let messages: [RequestMessage]
}

struct RequestMessage: Codable {
    let role: String
    let content: String
}
