//
//  FundmentalAgent.swift
//  JSMacroChart
//
//  Created by yangjs on 10/21/25.
//

import Foundation

class FundamentalAgent: Agent {
    var llm: any LLM
    var tool: (any Tool)?
    
    var prompt: String = """
    당신은 전문 기업 분석가이자 펀더멘털 애널리스트입니다.
    당신의 임무는 제공된 기업 재무 데이터를 분석하고 기업 가치와 투자 매력도를 평가하는 것입니다.
    
    다음 요소들을 중심으로 분석해야 합니다:
    - 매출액 증가율과 성장성
    - 영업이익률과 수익성
    - 순이익 변화와 안정성
    - 부채비율과 재무 건전성
    - 현금흐름과 유동성
    - 산업 내 경쟁력과 시장 지위
    
    분석 결과는 **마크다운(Markdown) 형식**으로 작성하며, 명확한 섹션(예: ## 재무 개요, ## 성장성 분석, ## 수익성 분석, ## 재무 안정성, ## 투자 결론)을 포함해야 합니다.
    
    마지막에는 반드시 기업 가치 관점에서 다음 세 가지 중 하나의 추천으로 결론을 내려야 합니다: **[BUY]**, **[SELL]**, 또는 **[HOLD]**, 그리고 그 이유를 명확하게 제시해야 합니다.
    
    특히 장기 투자 관점에서 기업의 내재 가치와 성장 잠재력을 중심으로 분석해주세요.
    """
    
    init(llm: any LLM = ChatGPT(), tool: (any Tool)? = StockPerformanceTool()) {
        self.llm = llm
        self.tool = tool
    }
    
    /// input = "TRUE|CODE" (해외 주식) 또는 "FALSE|CODE" (국내 주식)
    func execute(with input: String) async throws -> String {
        // 1. tool이 있는지 확인
        guard let tool = self.tool else {
            throw AgentError.toolNotFound
        }
        
        // 2. Tool을 실행하여 기업 재무 데이터(문자열)를 가져옴
        let stockPerformanceString = try await tool.execute(args: input)
        
        // 3. 입력 파싱
        let inputComponents = input.split(separator: "|")
        let isOverseas = inputComponents[0] == "TRUE"
        let stockCode = String(inputComponents[1])
        
        // 4. LLM에 전달할 메시지 생성
        let userMessage = """
        Stock Code: \(stockCode)
        Market Type: \(isOverseas ? "해외 주식" : "국내 주식")
        Financial Performance Data (JSON String):
        \(stockPerformanceString)
        
        위의 재무 데이터를 바탕으로 기업의 펀더멘털을 분석하고 투자 추천을 제시해주세요.
        특히 다음 항목들을 중점적으로 분석해주세요:
        - 매출 성장성과 지속가능성
        - 수익성 지표와 마진 분석
        - 재무 구조의 건전성
        - 현금 창출 능력
        - 장기 성장 동력과 경쟁 우위
        """
        
        let messages = [
            ChatMessage(role: .system, content: self.prompt),
            ChatMessage(role: .user, content: userMessage)
        ]
        
        // 5. LLM을 호출하여 분석 결과 받기
        let analysisResult = try await llm.sendMessage(messages: messages, model: "gpt-4o")
        
        return analysisResult.content
    }
    
    enum AgentError: Error {
        case toolNotFound
        case dataProcessingError
    }
}
