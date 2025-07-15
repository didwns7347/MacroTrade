//
//  Date +.swift
//  JSMacroChart
//
//  Created by yangjs on 7/14/25.
//

import Foundation

extension Date {
    func toStringYYYYMMDD() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
}
