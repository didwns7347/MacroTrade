import Foundation
import Combine

@MainActor
class AgentViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isSending: Bool = false

    private let openAIService = OpenAIService()
    private let repository = KoreaInvestmentUserAssetRepository()
    
    init() {
        // 초기 시스템 메시지 설정 (선택 사항)
        messages.append(ChatMessage(role: .system, content: "You are a helpful assistant."))
    }
    
    func fetchStockMovements(stocks: [StockAsset]) {
        Task {
            for stock in stocks {
                do {
                    let closingPrices = try await repository.getStockMovement(stock: stock)
                    print(closingPrices.closingPrices.count, stock.name, closingPrices.closingPrices.first ?? "")
                } catch {
                    print("FUCK ERROR \(error)")
                }
              
            }
        }
    }

    func sendMessage() {
        guard !currentInput.isEmpty else { return }
        
        isSending = true
        let newUserMessage = ChatMessage(role: .user, content: currentInput)
        messages.append(newUserMessage)
        currentInput = ""
        
        Task {
            defer { isSending = false }
            do {
                // API에 보낼 메시지 목록 (시스템 메시지 포함)
                let messagesToSend = messages
                let responseMessage = try await openAIService.sendMessage(messages: messagesToSend)
                messages.append(responseMessage)
            } catch {
                print("Error sending message: \(error)")
                let errorMessage = ChatMessage(role: .assistant, content: "Sorry, I encountered an error. Please check your API key and network connection.")
                messages.append(errorMessage)
            }
        }
    }
    
    
}
