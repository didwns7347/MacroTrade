//
//  Tool.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//
import Foundation
protocol Tool {
    func execute(args: String) async throws -> String
}

enum ToolError: Error {
    case encodingError
}
