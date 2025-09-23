//
//  UserAsset+Extensions.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import Foundation


// MARK: - Decimal 확장 (통화 포맷팅)
extension Decimal {
    func currencyFormatted(for assetType: AssetType) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        switch assetType {
        case .domestic:
            formatter.currencyCode = "KRW"
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
        case .overseas:
            formatter.currencyCode = "USD"
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 4

        }
        
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}



