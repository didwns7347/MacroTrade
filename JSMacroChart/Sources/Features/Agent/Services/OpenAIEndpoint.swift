import Foundation

enum OpenAIEndpoint {
    case chat(requestBody: Encodable)
}

extension OpenAIEndpoint: EndPoint {
    var baseURL: URL {
        return URL(string: "https://api.openai.com")!
    }

    var path: String {
        switch self {
        case .chat:
            return "/v1/chat/completions"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .chat:
            return .post
        }
    }

    var headers: [String : String]? {
        let apiKey = APIKeyManager.getAPIKey()
        return [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
    }
    
    var parameters: [String : Any]? {
        return nil
    }

    var requestBody: Encodable? {
        switch self {
        case .chat(let body):
            return body
        }
    }
}
