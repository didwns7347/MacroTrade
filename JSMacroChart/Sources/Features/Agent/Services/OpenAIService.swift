import Foundation

// MARK: - API Key Manager
enum APIKeyManager {
    static func getAPIKey() -> String {
        // Info.plist에서 API 키를 가져옵니다.
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !apiKey.isEmpty,
              !apiKey.starts(with: "$(") else {
            fatalError("Info.plist에 `OPENAI_API_KEY`를 설정해야 합니다. Config.xcconfig의 값이 올바르게 반영되었는지 확인하세요.")
        }
        return apiKey
    }
}

// MARK: - OpenAI Service
class OpenAIService {
    
    private let networkService: NetworkService

    init(networkService: NetworkService = APINetworkService.shared) {
        self.networkService = networkService
    }

    func sendMessage(messages: [ChatMessage], model: String = "gpt-3.5-turbo") async throws -> ChatMessage {
        let requestMessages = messages.map { RequestMessage(role: $0.role.rawValue, content: $0.content) }
        let requestBody = OpenAIRequest(model: model, messages: requestMessages)
        
        let endpoint = OpenAIEndpoint.chat(requestBody: requestBody)
        
        do {
            let openAIResponse: OpenAIResponse = try await networkService.request(endpoint: endpoint)
            guard let responseMessage = openAIResponse.choices.first?.message else {
                throw NetworkError.invalidResponse
            }
            return ChatMessage(role: .assistant, content: responseMessage.content)
        } catch {
            // APINetworkService에서 이미 에러를 로깅하고 있으므로, 여기서는 에러를 다시 던지기만 합니다.
            throw error
        }
    }
}