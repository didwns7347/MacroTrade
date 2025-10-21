//
//  ChartistAgent.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//

import Foundation

class ChartistAgent: Agent {
    var llm: LLM
    var tool: Tool?
    
    var prompt: String = """
    당신은 전문 주식 차트 분석가입니다.
    당신의 임무는 제공된 주가 데이터를 분석하고 투자 추천을 제시하는 것입니다.
    이동평균선(5,20,60), RSI, MACD 등의 기술적 지표를 기반으로 주식이 상승 추세인지 하락 추세인지를 판단해야 합니다.

    분석 결과는 **마크다운(Markdown) 형식**으로 작성하며, 명확한 섹션(예: ## 개요, ## 기술적 분석, ## 결론)을 포함해야 합니다.

    마지막에는 반드시 다음 세 가지 중 하나의 추천으로 결론을 내려야 합니다: **[BUY]**, **[SELL]**, 또는 **[HOLD]**, 그리고 그 이유를 명확하게 제시해야 합니다.
    """
    
    init(llm: LLM = ChatGPT(), tool: Tool? = StockPriceHistoryTool()) {
        self.llm = llm
        self.tool = tool
    }
    
    func execute(with input: String) async throws -> String {
        // 1. tool이 있는지 확인
        guard let tool = self.tool else {
            throw AgentError.toolNotFound
        }
        
        // 2. Tool을 실행하여 주식 데이터(문자열)를 가져옴. input은 종목 코드.
        let stockDataString = try await tool.execute(args: input)
        
        // 3. LLM에 전달할 메시지 생성
        let userMessage = """
        Stock Code: \(input)
        Price Data (JSON String):
        \(stockDataString)
        
        Please analyze the data above and provide a recommendation.
        """
        
        let messages = [
            ChatMessage(role: .system, content: self.prompt),
            ChatMessage(role: .user, content: userMessage)
        ]
        
        // 4. LLM을 호출하여 분석 결과 받기
        // 참고: llm.sendMessage의 모델 파라미터는 필요에 따라 수정해야 할 수 있습니다.
        let analysisResult = try await llm.sendMessage(messages: messages, model: "gpt-4o")
        
        return analysisResult.content
    }
    
    enum AgentError: Error {
        case toolNotFound
        case dataProcessingError
    }
}

