//
//  Untitled.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//

protocol Agent {
    var llm : LLM { get }
    var tool : Tool?  { get }
    var prompt : String { get }
    func execute(with input: String) async throws -> String
}
