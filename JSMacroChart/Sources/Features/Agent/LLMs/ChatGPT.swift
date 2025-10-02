//
//  ChatGPT.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//

class ChatGPT: LLM {
    func sendMessage(messages: [ChatMessage], model: String) async throws -> ChatMessage {
        let openAPIService = OpenAIService()
        return try await openAPIService.sendMessage(messages: messages, model: model)
    }
}
