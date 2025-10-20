//
//  Codeable +.swift
//  JSMacroChart
//
//  Created by yangjs on 10/20/25.
//
import Foundation

extension Encodable {
    func toJSONString(prettyPrinted: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting = .prettyPrinted
        }
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
