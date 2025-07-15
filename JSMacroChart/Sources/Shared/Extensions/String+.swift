//
//  String+.swift
//  JSMacroChart
//
//  Created by yangjs on 7/14/25.
//

import Foundation

extension String {
    func convertToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")       // ⏰ 한국 시간대 설정
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: self) {
            return date
        }
        return nil
    }
}
