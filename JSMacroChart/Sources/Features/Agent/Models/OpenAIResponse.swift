import Foundation

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: ResponseMessage
}

struct ResponseMessage: Codable {
    let role: String
    let content: String
}
