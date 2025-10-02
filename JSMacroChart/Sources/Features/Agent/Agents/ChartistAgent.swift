//
//  ChartistAgent.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//

class ChartistAgent: Agent {
    var llm: LLM
    
    var tool: Tool?
    
    var prompt: String
    
    init(llm: LLM = ChatGPT(), tool: Tool? = nil, prompt: String) {
        self.llm = llm
        self.tool = tool
        self.prompt = prompt
    }
    

    
    func execute(with input: String) async throws -> String {
        return ""
    }
    
    
}
