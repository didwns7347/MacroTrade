//
//  Tool.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//

protocol Tool {
    func execute() throws -> [String: Any]
}
