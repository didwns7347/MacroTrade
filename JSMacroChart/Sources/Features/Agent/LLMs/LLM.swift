//
//  LLM.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//

import Foundation

/// 대규모 언어 모델과의 상호작용을 위한 프로토콜을 정의합니다.
protocol LLM {
    
    /// 일련의 메시지를 언어 모델에 보내고 단일 응답을 검색합니다.
    /// - Parameters:
    ///   - messages: 대화 기록을 나타내는 `ChatMessage` 객체의 배열입니다.
    ///   - model: 사용할 모델의 식별자입니다 (예: "gpt-4-turbo").
    /// - Returns: 어시스턴트의 응답 메시지(`ChatMessage`).
    /// - Throws: 요청이 실패할 경우 오류를 발생시킵니다.
    func sendMessage(messages: [ChatMessage], model: String) async throws -> ChatMessage
    
    /*
    // 향후 스트리밍 응답을 위해 고려해볼 수 있는 함수입니다.
    /// 메시지 시퀀스를 보내고 응답을 스트리밍으로 다시 받습니다.
    /// - Parameters:
    ///   - messages: 대화 기록을 나타내는 `ChatMessage` 객체의 배열입니다.
    ///   - model: 사용할 모델의 식별자입니다.
    /// - Returns: 어시스턴트 응답의 일부를 생성하는 `AsyncThrowingStream<String, Error>`입니다.
    func streamMessage(messages: [ChatMessage], model: String) -> AsyncThrowingStream<String, Error>
    */
}